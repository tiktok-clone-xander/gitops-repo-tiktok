# tiktok-gitops

GitOps Deployment Repository cho TikTok Clone - quản lý bởi ArgoCD.

## Mô hình GitOps chuẩn Production

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        GITOPS ARCHITECTURE                              │
│                                                                         │
│  ┌──────────────┐     ┌──────────────────┐     ┌──────────────────┐    │
│  │  tiktok-app  │     │  tiktok-gitops   │     │ tiktok-infra     │    │
│  │  (CI Repo)   │     │  (CD Repo)       │     │ (IaC Repo)       │    │
│  │              │     │                  │     │                  │    │
│  │ Source Code  │────▶│ Helm Charts      │     │ Terraform        │    │
│  │ Dockerfiles  │     │ ArgoCD Apps      │     │ EKS/GKE/AKS     │    │
│  │ CI Pipeline  │     │ Env Configs      │     │ VPC/Network      │    │
│  │ Tests        │     │ Monitoring       │     │ IAM/Security     │    │
│  └──────────────┘     └────────┬─────────┘     └──────────────────┘    │
│         │                      │                                        │
│         │ Push Image           │ Watch                                  │
│         ▼                      ▼                                        │
│  ┌──────────────┐     ┌──────────────────┐     ┌──────────────────┐    │
│  │   GHCR /     │     │    ArgoCD        │     │   Kubernetes     │    │
│  │   ECR        │     │  (GitOps Agent)  │────▶│   Cluster        │    │
│  └──────────────┘     └──────────────────┘     └──────────────────┘    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Repository Structure

```
tiktok-gitops/
├── .github/workflows/
│   ├── update-image-tags.yml    # Triggered by CI repo
│   ├── promote-environment.yml  # Promote dev → staging → prod
│   └── rollback.yml             # Emergency rollback
├── apps/                        # ArgoCD Application manifests
│   ├── dev/
│   │   └── tiktok-clone.yaml
│   ├── staging/
│   │   └── tiktok-clone.yaml
│   └── production/
│       └── tiktok-clone.yaml
├── argocd/                      # ArgoCD system configs
│   ├── appproject.yaml
│   ├── argocd-cm.yaml
│   ├── argocd-rbac-cm.yaml
│   └── notifications-config.yaml
├── helm/                        # Helm charts
│   └── tiktok-clone/
│       ├── Chart.yaml
│       ├── values.yaml          # Base values
│       ├── templates/           # K8s resource templates
│       └── charts/              # Sub-charts
├── environments/                # Environment-specific overrides
│   ├── dev/
│   │   └── values.yaml
│   ├── staging/
│   │   └── values.yaml
│   └── production/
│       └── values.yaml
├── monitoring/                  # Monitoring configs
│   ├── prometheus/
│   ├── grafana/
│   └── alertmanager/
└── README.md
```

## Workflow

1. **Developer** push code lên `tiktok-app` (Application Repo)
2. **CI Pipeline** build, test, push Docker image lên GHCR
3. **CI** trigger `repository_dispatch` tới repo này (`tiktok-gitops`)
4. **CD Pipeline** update image tags trong environment values
5. **ArgoCD** detect thay đổi trên repo này → auto sync lên K8s
6. **ArgoCD** báo cáo trạng thái sync qua Slack/Teams

## Environments

| Branch | Environment | ArgoCD App           | Auto Sync              |
| ------ | ----------- | -------------------- | ---------------------- |
| main   | dev         | tiktok-clone-dev     | ✅ Yes                 |
| main   | staging     | tiktok-clone-staging | ✅ Yes (after promote) |
| main   | production  | tiktok-clone-prod    | ❌ Manual approve      |

## Setup

### Prerequisites

- ArgoCD installed trên K8s cluster
- `GHCR_TOKEN` secret để pull images
- GitHub PAT (`GITOPS_PAT`) trên App repo để trigger workflows

### Install ArgoCD Apps

```bash
# Apply project
kubectl apply -f argocd/appproject.yaml

# Apply applications per environment
kubectl apply -f apps/dev/tiktok-clone.yaml
kubectl apply -f apps/staging/tiktok-clone.yaml
kubectl apply -f apps/production/tiktok-clone.yaml
```

### Promote Changes

```bash
# Dev → Staging (automatic via workflow)
# Staging → Production (requires approval)
gh workflow run promote-environment.yml -f source=dev -f target=staging
gh workflow run promote-environment.yml -f source=staging -f target=production
```
