# DevMatch

A developer-first collaboration platform that connects software engineers, students, and IT enthusiasts through skill-based project matching. Project owners publish tasks with required skills; developers browse and apply for tasks that match their stack. Think LinkedIn meets Tinder, but for building things together.

---

## Table of Contents

- [What it does](#what-it-does)
- [Architecture overview](#architecture-overview)
- [Tech stack](#tech-stack)
- [Repository layout](#repository-layout)
- [Backend](#backend)
- [Mobile client](#mobile-client)
- [Infrastructure](#infrastructure)
- [CI/CD pipeline](#cicd-pipeline)
- [Observability](#observability)
- [Local setup](#local-setup)
- [Environment variables](#environment-variables)
- [API reference](#api-reference)

---

## What it does

1. **Register & build a profile** — add your skills (Flutter, Java, PostgreSQL, etc.) from a curated tag library
2. **Swipe through projects** — a Tinder-style swipe UI shows open project tasks matched to your skills
3. **Apply to tasks** — one tap to apply; the project owner sees your profile and email
4. **Manage your projects** — create projects, add tasks with required skills, accept or reject applicants
5. **Stay connected** — accepted applicants have their email surfaced directly to the project owner

---

## Architecture overview

```
┌──────────────────────────────────────────────────────────────────┐
│                        Flutter App (Android)                      │
│  Swipe · Explore · Projects · Profile                            │
└────────────────────────────┬─────────────────────────────────────┘
                             │ HTTPS REST
┌────────────────────────────▼─────────────────────────────────────┐
│                    Spring Boot REST API                           │
│  Auth · Projects · Tasks · Skills · Applications · Users         │
│  JWT auth · Rate limiting · Prometheus metrics                   │
└────────────────────────────┬─────────────────────────────────────┘
                             │
              ┌──────────────▼──────────────┐
              │   PostgreSQL (Aiven Cloud)   │
              └─────────────────────────────┘

─── Kubernetes (k3d / k3s) ──────────────────────────────────────────
  ArgoCD          watches helm-updates branch → deploys automatically
  Vault           injects DB + JWT secrets into pod at startup
  Prometheus      scrapes /actuator/prometheus every 15s
  Grafana         JVM + Spring Boot dashboards, connected to Prometheus
  Loki + Promtail collects pod logs, queryable in Grafana
```

---

## Tech stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.44, Dart, go_router, shadcn_ui, flutter_secure_storage |
| Backend | Java 21, Spring Boot 4, Spring Security, Hibernate 7, Bucket4j |
| Database | PostgreSQL 17 (Aiven managed cloud) |
| Auth | JWT (HMAC-SHA256), BCrypt password hashing |
| Container | Docker (multi-stage build, eclipse-temurin:21-jre-alpine) |
| Orchestration | Kubernetes via k3d (local) / k3s (server) |
| GitOps | ArgoCD — auto-sync on `helm-updates` branch |
| Secrets | HashiCorp Vault (dev mode locally), Vault agent sidecar injection |
| Metrics | Micrometer + Prometheus + Grafana (kube-prometheus-stack) |
| Logs | Loki + Promtail |
| CI | GitHub Actions — test → SpotBugs → build → push GHCR → update Helm |

---

## Repository layout

```
├── server/                   Spring Boot backend
│   ├── src/main/java/        Application source
│   ├── src/test/java/        Unit + integration tests (76 tests)
│   ├── Dockerfile            Multi-stage build
│   ├── entrypoint.sh         Reads Vault secrets → exports as env vars → JVM
│   └── spotbugs-exclude.xml  SpotBugs suppression rules
│
├── client/                   Flutter mobile app
│   ├── lib/
│   │   ├── main.dart         App entry, routing, bottom nav
│   │   ├── api.dart          ApiClient + all DTOs
│   │   ├── auth.dart         Login / register / token storage
│   │   ├── screens/          One file per screen
│   │   └── widgets/          Reusable UI components
│   └── test/                 Widget tests
│
├── helm/                     Helm chart for the backend
│   ├── Chart.yaml
│   ├── values.yaml           Image tag, resources, secrets config
│   └── templates/
│       ├── deployment.yaml   Vault sidecar annotations, Prometheus annotations
│       ├── service.yaml      ClusterIP on 8080
│       └── ingress.yaml      Nginx ingress (disabled by default)
│
├── argo/
│   └── application.yaml      ArgoCD Application — watches helm-updates branch
│
├── observability/
│   ├── install.sh            One-shot Helm install for monitoring stack
│   ├── prometheus-values.yaml kube-prometheus-stack config + DevMatch dashboards
│   └── loki-values.yaml      Loki + Promtail config
│
└── setup.sh                  Full local environment setup (Mac, one command)
```

---

## Backend

### Domain model

```
User ─< Application >─ ProjectTask ─< Project
User ─< UserSkill >─ SkillTag
ProjectTask ─< TaskSkill >─ SkillTag
```

- **User** — email, first/last name, username, bio, Discord, GitHub, skills
- **Project** — title, description, owner (User), tasks
- **ProjectTask** — title, description, required skills
- **Application** — links a User to a ProjectTask; status: `PENDING` → `ACCEPTED` / `REJECTED`
- **SkillTag** — global tag library (Java, Flutter, PostgreSQL, …); name casing preserved

### Security

- Stateless JWT auth — token in `Authorization: Bearer <token>` header
- BCrypt password hashing
- Rate limiter (Bucket4j): 10 req/min on `/api/auth/**`, 60 req/min elsewhere
- `/actuator/health` and `/actuator/prometheus` are publicly accessible (no auth)

### Key behaviours

- `GET /api/projects` returns a paginated `PageResponse { content, last }`, not a plain array
- `GET /api/projects?ownerId=X` returns a flat list of that owner's projects
- `GET /api/users/me/relevant-tasks` returns tasks whose required skills intersect with the current user's skills
- Seed data runs on startup — creates 28 default skill tags and ~45 sample projects

---

## Mobile client

### Screens

| Screen | Route | Description |
|---|---|---|
| Login | `/login` | Email + password, JWT stored in secure storage |
| Register | `/register` | 4-step flow: first name → last name → email → password |
| Match (home) | `/` | Tinder-style swipe cards showing matched project tasks |
| Explore | `/` tab 2 | Infinite-scroll paginated project list with search |
| Projects | `/` tab 3 | **My Projects** (manage incoming applications, accept/reject) + **Applied** (track your own applications) |
| Profile | `/` tab 4 | Edit skills, view profile, sign out |
| Project Detail | `/projects/:id` | Full project view with tasks and application status |
| Create Project | `/projects/create` | Create project + add tasks + attach skills |

### Navigation

4-tab bottom nav: **DevMatch** (swipe) · **Explore** · **Projects** · **Profile**

The Projects tab opens directly on the "My Projects" sub-tab so project owners can immediately see and act on incoming applications.

### Key details

- Accepted applicant's email is shown in the My Projects panel for direct contact
- Skill selection uses a chip grid (not a text search) on both profile and project creation
- Token is stored with `flutter_secure_storage` (AES-encrypted on Android)
- All API calls go through `ApiClient` in `api.dart` — a single `const _base` URL

---

## Infrastructure

### Kubernetes namespaces

| Namespace | Contents |
|---|---|
| `devmatch` | Spring Boot app pod (+ Vault sidecar) |
| `argocd` | ArgoCD controller, server, repo server |
| `vault` | HashiCorp Vault (dev mode) |
| `monitoring` | Prometheus, Grafana, Loki, Promtail |

### Vault secret injection

The Deployment's pod spec carries Vault annotations. When a pod starts:

1. Vault init container authenticates using the pod's Kubernetes service account
2. Fetches secrets from `secret/devmatch` (DB_URL, DB_USERNAME, DB_PASSWORD, JWT_SECRET, JWT_EXPIRATION_MS)
3. Writes each as a file under `/vault/secrets/`
4. `entrypoint.sh` reads those files and exports them as env vars before starting the JVM

The app never sees credentials in env vars at image build time — they arrive at runtime only.

### GHCR image pull

The cluster uses a Kubernetes `docker-registry` secret named `ghcr-pull-secret` in the `devmatch` namespace to pull the private GHCR image. Create it once:

```bash
kubectl create secret docker-registry ghcr-pull-secret \
  --namespace devmatch \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_PAT_WITH_READ_PACKAGES
```

### ArgoCD

- Watches the `helm-updates` branch (not `main`) — this avoids the branch protection rule that blocks direct pushes to `main`
- Auto-sync with `prune: true` and `selfHeal: true`
- UI at `http://localhost:8081` (after port-forward)

---

## CI/CD pipeline

### Backend CI (`.github/workflows/backend-ci.yml`)

Triggers on push/PR to `main` when `server/**` changes.

```
push to main
  └─ Job 1: Test & SpotBugs
       ├─ ./mvnw test -Dspring.profiles.active=test   (76 tests, H2 in-memory)
       └─ ./mvnw spotbugs:check                       (static analysis)
  └─ Job 2: Build & Push  (main push only, after Job 1)
       ├─ Build Docker image
       ├─ Push to GHCR as :latest and :<sha>
       └─ Checkout helm-updates branch
            └─ Update helm/values.yaml tag → push to helm-updates
                 └─ ArgoCD detects change → rolling deploy
```

### Flutter CI (`.github/workflows/flutter-ci.yml`)

Triggers on push/PR to `main` and `develop`.

```
push
  └─ Job 1: Analyze & Test
       ├─ flutter analyze --fatal-infos
       └─ flutter test --coverage
  └─ Job 2: Build APK  (main push only)
       └─ flutter build apk --release → uploaded as artifact
```

---

## Observability

All services run in the `monitoring` namespace.

| Service | Access | Credentials |
|---|---|---|
| Grafana | `http://localhost:3000` | admin / `$GRAFANA_ADMIN_PASSWORD` |
| Prometheus | `http://localhost:9091` | none |
| Loki | `http://localhost:3100` | none |

Grafana comes pre-loaded with two dashboards in the **DevMatch** folder:
- **JVM (Micrometer)** — heap, GC pause time, threads, CPU usage
- **Kancy Spring Boot Statistics** — HTTP request rate, error rate, latency percentiles

Prometheus scrapes `/actuator/prometheus` on `devmatch-server.devmatch.svc.cluster.local:8080` every 15s.

Promtail collects logs from all pods labelled `app: devmatch-server` and ships them to Loki. Add Loki as a Grafana datasource manually: `http://loki.monitoring.svc.cluster.local:3100`

Port-forwards (started by `setup.sh`, restart after reboot):
```bash
kubectl port-forward -n argocd     svc/argocd-server                 8081:80   &
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana  3000:80   &
kubectl port-forward -n vault      svc/vault                          8200:8200 &
kubectl port-forward -n devmatch   svc/devmatch-server                9090:8080 &
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9091:9090 &
kubectl port-forward -n monitoring svc/loki                           3100:3100 &
```

---

## Local setup

### Prerequisites

- Docker Desktop running
- macOS (Homebrew)

### One command

```bash
./setup.sh
```

This installs k3d / kubectl / helm, creates a k3d cluster, sets up namespaces, installs Vault + ArgoCD + the full observability stack, builds the Docker image locally, and starts port-forwards.

Requires `server/.env` — copy from `.env.example` and fill in real values:

```bash
cp server/.env.example server/.env
# edit server/.env
./setup.sh
```

After setup:

| Service | URL | Credentials |
|---|---|---|
| Backend API | `http://localhost:9090` | — |
| Grafana | `http://localhost:3000` | admin / see `$GRAFANA_ADMIN_PASSWORD` |
| Vault | `http://localhost:8200` | token: see `$VAULT_ROOT_TOKEN` |
| ArgoCD | `http://localhost:8081` | admin / printed by setup.sh |

### Running tests

```bash
# Backend (76 tests, uses H2 in-memory DB)
cd server && ./mvnw test -Dspring.profiles.active=test

# SpotBugs static analysis (requires JDK ≤22 locally — JDK 25 not yet supported by SpotBugs ASM)
JAVA_HOME=/path/to/jdk21 ./mvnw spotbugs:check -DskipTests

# Flutter
cd client && flutter test --coverage
```

---

## Environment variables

All secrets are read from `server/.env` at startup. Never commit this file.

| Variable | Description | Default |
|---|---|---|
| `DB_URL` | JDBC connection string | — |
| `DB_USERNAME` | Database user | — |
| `DB_PASSWORD` | Database password | — |
| `DB_DRIVER` | JDBC driver class | `org.postgresql.Driver` |
| `JWT_SECRET` | HMAC-SHA256 signing key (min 32 chars) | — |
| `JWT_EXPIRATION_MS` | Token lifetime in ms | `86400000` (24h) |
| `SERVER_PORT` | HTTP port | `8080` |
| `JPA_DDL_AUTO` | Hibernate schema mode | `update` |
| `JPA_SHOW_SQL` | Log SQL statements | `false` |
| `HIBERNATE_DIALECT` | Hibernate dialect | `PostgreSQLDialect` |
| `GRAFANA_ADMIN_PASSWORD` | Grafana admin password | — |
| `VAULT_ROOT_TOKEN` | Vault dev root token | `root` |

---

## API reference

All endpoints except auth and public GETs require `Authorization: Bearer <token>`.

### Auth

| Method | Path | Body | Description |
|---|---|---|---|
| `POST` | `/api/auth/register` | `{email, firstName, lastName, password}` | Register and receive JWT |
| `POST` | `/api/auth/login` | `{email, password}` | Login and receive JWT |

### Users

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/users/me` | Current user profile |
| `PUT` | `/api/users/me` | Update profile |
| `GET` | `/api/users/{id}` | Get user by ID |
| `GET` | `/api/users/me/applications` | All applications submitted by current user |
| `GET` | `/api/users/me/relevant-tasks` | Tasks whose skills match current user's skills |
| `POST` | `/api/users/me/skills/{skillId}` | Add skill to profile |
| `DELETE` | `/api/users/me/skills/{skillId}` | Remove skill from profile |
| `GET` | `/api/users/me/skills` | List current user's skills |

### Projects

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/projects?page=0&size=10` | Paginated project list → `{content, last}` |
| `GET` | `/api/projects?ownerId={id}` | Flat list of one owner's projects |
| `GET` | `/api/projects/{id}` | Project detail with tasks |
| `POST` | `/api/projects` | Create project (auth required) |
| `PUT` | `/api/projects/{id}` | Update project (owner only) |
| `DELETE` | `/api/projects/{id}` | Delete project (owner only) |

### Tasks

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/projects/{projectId}/tasks` | All tasks for a project |
| `GET` | `/api/projects/{projectId}/tasks/{taskId}` | Task detail |
| `POST` | `/api/projects/{projectId}/tasks` | Create task |
| `PUT` | `/api/projects/{projectId}/tasks/{taskId}` | Update task |
| `DELETE` | `/api/projects/{projectId}/tasks/{taskId}` | Delete task |
| `POST` | `/api/projects/{projectId}/tasks/{taskId}/skills/{skillId}` | Add skill to task |
| `DELETE` | `/api/projects/{projectId}/tasks/{taskId}/skills/{skillId}` | Remove skill from task |

### Applications

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/projects/{projectId}/tasks/{taskId}/applications` | Apply to a task |
| `GET` | `/api/projects/{projectId}/tasks/{taskId}/applications` | List applications (owner only) |
| `PUT` | `/api/projects/{projectId}/tasks/{taskId}/applications/{appId}` | Update status: `ACCEPTED` / `REJECTED` |
| `DELETE` | `/api/projects/{projectId}/tasks/{taskId}/applications/{appId}` | Withdraw application |

### Skills

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/skills` | All skill tags |
| `GET` | `/api/skills/search?q={query}` | Search skills by name |
| `GET` | `/api/skills/{id}` | Get skill by ID |
| `POST` | `/api/skills` | Create new skill tag (auth required) |
