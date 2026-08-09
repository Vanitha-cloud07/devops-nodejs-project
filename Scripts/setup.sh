#!/usr/bin/env bash
# One-shot bootstrap: provisions AWS infra with Terraform, points kubectl at
# the new EKS cluster, and installs the monitoring stack. Run stage by stage
# the first time (don't blindly `bash scripts/setup.sh` against a real AWS
# account) — see README.md for the full walkthrough.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== 1/4 Terraform init/plan/apply =="
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
cd ..

echo "== 2/4 Configure kubectl =="
CLUSTER_NAME=$(terraform -chdir=terraform output -raw cluster_name)
AWS_REGION=$(terraform -chdir=terraform output -raw cluster_endpoint | sed -n 's#https://.*\.\([a-z0-9-]*\)\.eks\.amazonaws\.com#\1#p')
aws eks update-kubeconfig --region "${AWS_REGION:-us-east-1}" --name "$CLUSTER_NAME"

echo "== 3/4 Install kube-prometheus-stack (Prometheus + Grafana) =="
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo update >/dev/null
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f monitoring/prometheus/values.yaml

echo "== 4/4 Deploy the app + ServiceMonitor + alerts =="
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/
kubectl apply -f monitoring/prometheus/service-monitor.yaml
kubectl apply -f monitoring/prometheus/alert-rules.yaml
kubectl apply -f monitoring/grafana/dashboard-configmap.yaml -n monitoring

echo "Done. See README.md for how to reach Grafana and the app."