#!/bin/bash

# Set variables
PROMETHEUS_RELEASENAME="prometheus"
GRAFANA_RELEASENAME="grafana"
NAMESPACE="monitoring"
PROMETHEUS_SVC="prometheus-server"
GRAFANA_SVC="grafana"

# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# Update Helm repositories
helm repo update

# Create namespace if it doesn't exist
kubectl get ns $NAMESPACE &>/dev/null || kubectl create ns $NAMESPACE

# Deploy Prometheus with NodePort service
helm upgrade --install $PROMETHEUS_RELEASENAME prometheus-community/prometheus \
  --namespace $NAMESPACE \
  --values="$PWD/Prometheus/values-prometheus.yaml" \
  --set server.service.type=NodePort \
  --set alertmanager.service.type=NodePort \
  --set pushgateway.service.type=NodePort

# Deploy Grafana with NodePort service and persistence enabled
helm upgrade --install $GRAFANA_RELEASENAME grafana/grafana \
  --namespace $NAMESPACE \
  --values="$PWD/Grafana/values-grafana.yaml" \
  --set service.type=NodePort \
  --set persistence.enabled=true

# Wait for pods to be in a ready state
echo "Waiting for Prometheus and Grafana pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=$PROMETHEUS_RELEASENAME -n $NAMESPACE --timeout=90s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=$GRAFANA_RELEASENAME -n $NAMESPACE --timeout=90s

# Port-forward services in the background
kubectl port-forward svc/$PROMETHEUS_SVC -n $NAMESPACE 9090:80 &>/dev/null &
kubectl port-forward svc/$GRAFANA_SVC -n $NAMESPACE 3000:80 &>/dev/null &

# Retrieve and display Minikube service URLs
if command -v minikube &>/dev/null; then
  PROMETHEUS_URL=$(minikube service -n $NAMESPACE $PROMETHEUS_SVC --url)
  GRAFANA_URL=$(minikube service -n $NAMESPACE $GRAFANA_SVC --url)
  echo "Prometheus URL: $PROMETHEUS_URL"
  echo "Grafana URL: $GRAFANA_URL"

  # Open URLs in the browser (if xdg-open is available)
  if command -v xdg-open &>/dev/null; then
    xdg-open "$PROMETHEUS_URL"
    xdg-open "$GRAFANA_URL"
  fi
else
  echo "Minikube is not installed or not running. URLs cannot be retrieved."
fi

