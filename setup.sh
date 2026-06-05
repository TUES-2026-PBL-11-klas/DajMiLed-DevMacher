#!/usr/bin/env bash
# DevMatch — local k3s environment setup
# Run once on any Mac to get the full stack running locally.
# Prerequisites: Docker Desktop must be running before you execute this.
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()     { echo -e "${RED}[FAIL]${NC} $*"; exit 1; }

ROOT="$(cd "$(dirname "$0")" && pwd)"

# ── 1. Check Docker ──────────────────────────────────────────────────────────
info "Checking Docker..."
docker info &>/dev/null || die "Docker is not running. Start Docker Desktop first."
success "Docker is running"

# ── 2. Install tools ─────────────────────────────────────────────────────────
info "Installing k3d, kubectl, helm (via Homebrew)..."
brew install k3d kubectl helm 2>&1 | grep -E "already installed|Installing|Pouring" || true
success "Tools ready: k3d $(k3d version | head -1 | awk '{print $3}'), helm $(helm version --short)"

# ── 3. Create k3d cluster ────────────────────────────────────────────────────
if k3d cluster list | grep -q "devmatch"; then
  warn "Cluster 'devmatch' already exists — skipping creation"
else
  info "Creating k3d cluster 'devmatch'..."
  k3d cluster create devmatch --port "8888:80@loadbalancer" --agents 1 --wait
  success "Cluster created"
fi

kubectl config use-context k3d-devmatch

# ── 4. Namespaces ────────────────────────────────────────────────────────────
info "Creating namespaces..."
for ns in devmatch argocd vault; do
  kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
done
success "Namespaces ready"

# ── 5. Secrets ───────────────────────────────────────────────────────────────
info "Loading secrets from server/.env..."
[ -f "$ROOT/server/.env" ] || die "server/.env not found — ask the team lead for this file (never committed to git)"

set -a; source "$ROOT/server/.env"; set +a
kubectl create secret generic devmatch-secrets -n devmatch \
  --from-literal=DB_URL="$DB_URL" \
  --from-literal=DB_USERNAME="$DB_USERNAME" \
  --from-literal=DB_PASSWORD="$DB_PASSWORD" \
  --from-literal=JWT_SECRET="$JWT_SECRET" \
  --from-literal=JWT_EXPIRATION_MS="${JWT_EXPIRATION_MS:-86400000}" \
  --dry-run=client -o yaml | kubectl apply -f -
success "Kubernetes secret applied"

# ── 6. Vault ─────────────────────────────────────────────────────────────────
info "Installing Vault..."
helm repo add hashicorp https://helm.releases.hashicorp.com --force-update &>/dev/null
VAULT_ROOT_TOKEN="${VAULT_ROOT_TOKEN:-root}"
helm upgrade --install vault hashicorp/vault \
  --namespace vault \
  --set "ui.enabled=true" \
  --set "server.dev.enabled=true" \
  --set "server.dev.devRootToken=$VAULT_ROOT_TOKEN" \
  --wait --timeout=120s &>/dev/null
success "Vault installed"

info "Configuring Vault..."
kubectl wait --for=condition=ready pod/vault-0 -n vault --timeout=60s &>/dev/null
kubectl exec -n vault vault-0 -- vault auth enable kubernetes 2>/dev/null || true
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.default.svc.cluster.local:443" &>/dev/null
kubectl exec -n vault vault-0 -- sh -c \
  'echo "path \"secret/data/devmatch\" { capabilities = [\"read\"] }" | vault policy write devmatch-policy -' &>/dev/null
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/role/devmatch \
  bound_service_account_names=devmatch-server \
  bound_service_account_namespaces=devmatch \
  policies=devmatch-policy ttl=1h &>/dev/null

# Store secrets in Vault (env already loaded above)
kubectl exec -n vault vault-0 -- vault kv put secret/devmatch \
  DB_URL="$DB_URL" DB_USERNAME="$DB_USERNAME" DB_PASSWORD="$DB_PASSWORD" \
  JWT_SECRET="$JWT_SECRET" JWT_EXPIRATION_MS="${JWT_EXPIRATION_MS:-86400000}" &>/dev/null

kubectl create serviceaccount devmatch-server -n devmatch --dry-run=client -o yaml | kubectl apply -f - &>/dev/null
success "Vault configured — secrets stored at secret/devmatch"

# ── 7. Argo CD ───────────────────────────────────────────────────────────────
info "Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml &>/dev/null
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=120s &>/dev/null

# Run in insecure (HTTP) mode
kubectl patch configmap argocd-cmd-params-cm -n argocd \
  --type merge -p '{"data":{"server.insecure":"true"}}' &>/dev/null
kubectl rollout restart deployment/argocd-server -n argocd &>/dev/null
kubectl rollout status deployment/argocd-server -n argocd --timeout=90s &>/dev/null

kubectl apply -f "$ROOT/argo/application.yaml" &>/dev/null
success "Argo CD installed and devmatch app registered"

# ── 8. Observability ─────────────────────────────────────────────────────────
info "Installing Prometheus + Grafana + Loki..."
bash "$ROOT/observability/install.sh" &>/dev/null
success "Observability stack installed"

# ── 9. Build & deploy backend ────────────────────────────────────────────────
info "Building Docker image..."
docker build -t devmatch-server:local "$ROOT/server" -q &>/dev/null
k3d image import devmatch-server:local -c devmatch &>/dev/null
success "Image built and imported into cluster"

info "Deploying backend via Helm..."
helm upgrade --install devmatch "$ROOT/helm" \
  --namespace devmatch \
  --set image.repository=devmatch-server \
  --set image.tag=local \
  --set image.pullPolicy=Never \
  --wait --timeout=120s &>/dev/null
success "Backend deployed"

# ── 10. Start port-forwards ──────────────────────────────────────────────────
info "Starting port-forwards..."
pkill -f "kubectl port-forward" 2>/dev/null || true
sleep 1

kubectl port-forward -n argocd     svc/argocd-server                  8081:80   &>/tmp/pf-argocd.log &
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana   3000:80   &>/tmp/pf-grafana.log &
kubectl port-forward -n vault      svc/vault                           8200:8200 &>/tmp/pf-vault.log &
kubectl port-forward -n devmatch   svc/devmatch-server                 9090:8080 &>/tmp/pf-backend.log &

sleep 3
success "Port-forwards running in background"

ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   DevMatch local environment is ready!    ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "  ${CYAN}Grafana${NC}  → http://localhost:3000       admin / ${GRAFANA_ADMIN_PASSWORD}"
echo -e "  ${CYAN}Vault${NC}    → http://localhost:8200       token: ${VAULT_ROOT_TOKEN}"
echo -e "  ${CYAN}Argo CD${NC}  → http://localhost:8081       admin / ${ARGOCD_PASS}"
echo -e "  ${CYAN}Backend${NC}  → http://localhost:9090/actuator/health"
echo ""
echo -e "${YELLOW}Port-forwards run in the background. Re-run ./setup.sh after a Mac reboot.${NC}"
