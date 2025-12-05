# ArgoCD Implementation

This directory contains ArgoCD application manifests for the G11 K8s Charts project using the **App of Apps** pattern.

## Overview

The App of Apps pattern allows you to manage multiple ArgoCD applications through a single "root" application. This makes it easy to deploy and manage all services in your platform from a single point of control.

## Structure

```
argocd/
├── root-app.yaml           # Root application (manages all apps in apps/ directory)
└── apps/                   # Individual service applications
    ├── category-service.yaml
    ├── comment-service.yaml
    ├── content-service.yaml
    ├── frontend-service.yaml
    ├── media-service.yaml
    ├── postgres-databases.yaml
    └── user-service.yaml
```

## Prerequisites

1. **ArgoCD installed**: You must have ArgoCD installed in your cluster
2. **kubectl access**: You need kubectl configured to access your cluster
3. **Git repository access**: Your cluster must be able to access the GitHub repository

## Quick Start

### Step 1: Apply the Root Application

```bash
kubectl apply -f argocd/root-app.yaml
```

This creates the root application in ArgoCD. The root app monitors the `argocd/apps/` directory and automatically creates child applications for each YAML file it finds.

### Step 2: Verify in ArgoCD UI

1. Access your ArgoCD UI
2. You should see the `root-app` application
3. Sync the `root-app` (if not auto-synced)
4. After syncing, all child applications should appear

### Step 3: Sync Applications

The applications are configured with automated sync, so they should automatically deploy. If needed, you can manually sync from the UI or CLI:

```bash
argocd app sync root-app
```

## Configuration

### Auto-Sync Policy

All applications are configured with:
- **Automated sync**: Changes in Git automatically sync to the cluster
- **Self-heal**: ArgoCD will automatically correct drift
- **Prune**: Removes resources when they're deleted from Git

### Namespaces

- **ArgoCD applications**: Deployed to `argocd` namespace
- **Services**: Deployed to `default` namespace

> **Note**: If you want to deploy to a different namespace, edit the `destination.namespace` field in each application YAML file.

## Adding New Services

To add a new service:

1. Create a Helm chart in `charts/your-service/`
2. Create an application manifest in `argocd/apps/your-service.yaml`
3. Commit and push to Git
4. ArgoCD will automatically pick up the new application

Example application manifest:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: your-service
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/G11-Engineering/g11-k8s-charts.git
    targetRevision: HEAD
    path: charts/your-service
    helm:
      releaseName: your-service
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

## Troubleshooting

### Root app not syncing
```bash
# Check root app status
argocd app get root-app

# Force sync
argocd app sync root-app
```

### Child applications not appearing
- Ensure the YAML files in `argocd/apps/` are valid
- Check ArgoCD logs: `kubectl logs -n argocd deployment/argocd-application-controller`

### Service not deploying
- Check the individual application status in ArgoCD UI
- Verify the Helm chart path is correct
- Ensure the chart has valid `Chart.yaml` and `values.yaml`

## CLI Commands

```bash
# List all applications
argocd app list

# Get app details
argocd app get <app-name>

# Sync an application
argocd app sync <app-name>

# Delete an application (from ArgoCD, not cluster)
argocd app delete <app-name>

# View sync status
argocd app wait <app-name>
```

## Best Practices

1. **Version Control**: Always commit ArgoCD manifests to Git
2. **Testing**: Test changes in a staging environment first
3. **Naming**: Use consistent naming across chart names and application names
4. **Monitoring**: Regularly check ArgoCD UI for sync status
5. **Secrets**: Use external secret management (e.g., Sealed Secrets, External Secrets Operator)

## Further Reading

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [App of Apps Pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)
- [Helm Integration](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/)
