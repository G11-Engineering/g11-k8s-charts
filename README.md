# CMS Blog Platform – Helm Charts

This repository contains the Helm charts used to deploy the CMS Blog Platform.
Each microservice has its own chart, and all images are pulled directly from Docker Hub under the `jasonmishi/g11-*` repositories.

These charts are kept simple to make them easier to read, learn, and customise.

---

## Folder structure

```
charts/
  user-service/
  content-service/
  media-service/
  category-service/
  comment-service/
  frontend-service/
```

Each chart contains:

```
Chart.yaml
values.yaml
templates/
  deployment.yaml
  service.yaml
  _helpers.tpl
```

The **media-service** chart also includes a `pvc.yaml` template for file uploads.

---

## Requirements

* Kubernetes cluster (minikube, kind, cloud, etc.)
* Helm 3+
* Docker images available on Docker Hub:

  * jasonmishi/g11-user-service
  * jasonmishi/g11-content-service
  * jasonmishi/g11-media-service
  * jasonmishi/g11-category-service
  * jasonmishi/g11-comment-service
  * jasonmishi/g11-frontend

---

## Create namespace

```bash
kubectl create ns cms
```

---

## Secrets

Some services need secrets such as JWT keys or Asgardeo client secrets.
Each chart expects a secret named using this pattern:

```
<release-name>-<chart-name>-secret
```

Example for the user service when installed with release name `user`:

```bash
kubectl -n cms create secret generic user-user-service-secret \
  --from-literal=JWT_SECRET="supersecret" \
  --from-literal=ASGARDEO_M2M_CLIENT_SECRET="asgardeo-secret"
```

Create similar secrets for content, media, category, and comment services as needed.

The frontend usually does not require secrets.

---

## Install charts

Below are the basic install commands. Adjust tags or values as needed.

### User service

```bash
helm upgrade --install user charts/user-service \
  --namespace cms \
  --set image.repository=jasonmishi/g11-user-service \
  --set image.tag=latest
```

### Content service

```bash
helm upgrade --install content charts/content-service \
  --namespace cms \
  --set image.repository=jasonmishi/g11-content-service \
  --set image.tag=latest
```

### Media service (uses a PVC)

```bash
helm upgrade --install media charts/media-service \
  --namespace cms \
  --set image.repository=jasonmishi/g11-media-service \
  --set image.tag=latest \
  --set persistence.enabled=true \
  --set persistence.size=5Gi
```

### Category service

```bash
helm upgrade --install category charts/category-service \
  --namespace cms \
  --set image.repository=jasonmishi/g11-category-service \
  --set image.tag=latest
```

### Comment service

```bash
helm upgrade --install comment charts/comment-service \
  --namespace cms \
  --set image.repository=jasonmishi/g11-comment-service \
  --set image.tag=latest
```

### Frontend service

```bash
helm upgrade --install frontend charts/frontend-service \
  --namespace cms \
  --set image.repository=jasonmishi/g11-frontend \
  --set image.tag=latest
```

---

## Check deployments

```bash
kubectl -n cms get all
kubectl -n cms get pods
```

Check logs for any service:

```bash
kubectl -n cms logs deployment/user-user-service
```

---

## Template rendering

Render a chart to inspect the generated Kubernetes YAML:

```bash
helm template user charts/user-service --namespace cms
```

---

## Chart customisation

You can modify each chart by editing:

* **values.yaml** for default service configuration
* **deployment.yaml** for environment variables or container settings
* **service.yaml** for port or type changes
* **pvc.yaml** (media only) for storage settings

These charts are intentionally simple so you can build on them as your needs grow.
