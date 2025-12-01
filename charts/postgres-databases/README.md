# PostgreSQL Databases Chart

This Helm chart deploys PostgreSQL database instances for the CMS Blog Platform microservices.

## Overview

This chart creates **5 separate PostgreSQL databases**, one for each microservice:

- **postgres-user**: Database for user-service
- **postgres-content**: Database for content-service
- **postgres-media**: Database for media-service
- **postgres-category**: Database for category-service
- **postgres-comment**: Database for comment-service

Each database runs as a StatefulSet with persistent storage to ensure data survives pod restarts.

## Prerequisites

- Kubernetes 1.19+
- Helm 3+
- PersistentVolume provisioner support in the underlying infrastructure
- At least 25Gi of available storage (5Gi per database)

## Installation

### 1. Create namespace

```bash
kubectl create namespace cms
```

### 2. Install the chart

```bash
helm install postgres-db charts/postgres-databases --namespace cms
```

Or with custom values:

```bash
helm install postgres-db charts/postgres-databases \
  --namespace cms \
  --set persistence.size=10Gi \
  --set image.tag=16-alpine
```

### 3. Verify installation

```bash
# Check StatefulSets
kubectl get statefulsets -n cms

# Check pods
kubectl get pods -n cms

# Check services
kubectl get services -n cms

# Check persistent volume claims
kubectl get pvc -n cms
```

## Configuration

The following table lists the configurable parameters and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | PostgreSQL image repository | `postgres` |
| `image.tag` | PostgreSQL image tag | `15-alpine` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `persistence.size` | Size of persistent volume per database | `5Gi` |
| `persistence.accessMode` | Access mode for persistent volume | `ReadWriteOnce` |
| `global.storageClass` | Storage class for PVCs | `""` (default) |
| `resources.limits.cpu` | CPU limit per database | `500m` |
| `resources.limits.memory` | Memory limit per database | `512Mi` |
| `resources.requests.cpu` | CPU request per database | `250m` |
| `resources.requests.memory` | Memory request per database | `256Mi` |
| `databases.user.enabled` | Enable user database | `true` |
| `databases.user.name` | User database name | `user_service` |
| `databases.user.username` | User database username | `user_service` |
| `databases.user.password` | User database password | `user_password` |

Similar parameters exist for `content`, `media`, `category`, and `comment` databases.

## Database Connection Strings

After installation, your microservices can connect using these connection strings:

```
postgresql://user_service:user_password@postgres-user:5432/user_service
postgresql://content_service:content_password@postgres-content:5432/content_service
postgresql://media_service:media_password@postgres-media:5432/media_service
postgresql://category_service:category_password@postgres-category:5432/category_service
postgresql://comment_service:comment_password@postgres-comment:5432/comment_service
```

## Accessing Databases

### Connect to a database pod

```bash
kubectl exec -it -n cms postgres-user-0 -- psql -U user_service -d user_service
```

### View logs

```bash
kubectl logs -n cms postgres-user-0
```

### Port forward for local access

```bash
kubectl port-forward -n cms postgres-user-0 5432:5432
```

Then connect locally:

```bash
psql -h localhost -U user_service -d user_service
```

## Customizing Database Configuration

### Change database passwords

Create a custom `values.yaml`:

```yaml
databases:
  user:
    password: "my-secure-password"
  content:
    password: "another-secure-password"
```

Install with custom values:

```bash
helm install postgres-db charts/postgres-databases -f custom-values.yaml --namespace cms
```

### Increase storage size

```bash
helm install postgres-db charts/postgres-databases \
  --namespace cms \
  --set persistence.size=20Gi
```

### Disable specific databases

```bash
helm install postgres-db charts/postgres-databases \
  --namespace cms \
  --set databases.comment.enabled=false
```

## Upgrading

```bash
helm upgrade postgres-db charts/postgres-databases --namespace cms
```

## Uninstalling

```bash
helm uninstall postgres-db --namespace cms
```

**Note**: This will delete the StatefulSets and Services, but PersistentVolumeClaims (PVCs) are retained by default to prevent data loss. To delete PVCs:

```bash
kubectl delete pvc -n cms -l app.kubernetes.io/instance=postgres-db
```

## Troubleshooting

### Pods not starting

Check pod status:

```bash
kubectl describe pod -n cms postgres-user-0
```

Common issues:
- Insufficient storage
- Storage class not available
- Resource limits too low

### Database connection failures

1. Verify pod is running:
   ```bash
   kubectl get pods -n cms
   ```

2. Check logs:
   ```bash
   kubectl logs -n cms postgres-user-0
   ```

3. Test connection from another pod:
   ```bash
   kubectl run -it --rm debug --image=postgres:15-alpine --restart=Never -n cms -- \
     psql -h postgres-user -U user_service -d user_service
   ```

### Storage issues

Check PVC status:

```bash
kubectl get pvc -n cms
```

If PVC is pending, check storage class:

```bash
kubectl get storageclass
```

## Security Considerations

⚠️ **IMPORTANT**: The default configuration uses hardcoded passwords in `values.yaml`. This is **NOT recommended for production**.

For production deployments:

1. **Use Kubernetes Secrets**:
   ```bash
   kubectl create secret generic postgres-user-secret \
     --from-literal=password=your-secure-password \
     -n cms
   ```

2. **Use external secret management** (AWS Secrets Manager, HashiCorp Vault, etc.)

3. **Enable network policies** to restrict database access

4. **Use TLS/SSL** for database connections

## Architecture

Each database is deployed as:

- **StatefulSet**: Ensures stable network identity and ordered deployment
- **Headless Service**: Provides network access with stable DNS names
- **PersistentVolumeClaim**: Stores database data persistently

This architecture ensures:
- Data persistence across pod restarts
- Stable network identities
- Independent scaling per database
- Isolation between services

## License

This chart is part of the CMS Blog Platform project.
