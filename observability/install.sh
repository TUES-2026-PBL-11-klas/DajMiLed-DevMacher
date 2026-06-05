#!/usr/bin/env bash
# Run this once on the k3s server to install the full observability stack.
# Requires GRAFANA_ADMIN_PASSWORD env var (read from server/.env by setup.sh).
set -euo pipefail

NAMESPACE=monitoring
GRAFANA_ADMIN_PASSWORD="${GRAFANA_ADMIN_PASSWORD:?GRAFANA_ADMIN_PASSWORD must be set (add it to server/.env)}"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "Installing Prometheus + Grafana..."
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --values "$(dirname "$0")/prometheus-values.yaml" \
  --set "grafana.adminPassword=$GRAFANA_ADMIN_PASSWORD" \
  --wait

echo "Installing Loki..."
helm upgrade --install loki grafana/loki-stack \
  --namespace $NAMESPACE \
  --values "$(dirname "$0")/loki-values.yaml" \
  --wait

echo ""
echo "Done. Add Loki as a datasource in Grafana:"
echo "  URL: http://loki.$NAMESPACE.svc.cluster.local:3100"
echo ""
echo "Grafana is available via:"
echo "  kubectl port-forward -n $NAMESPACE svc/kube-prometheus-stack-grafana 3000:80"
