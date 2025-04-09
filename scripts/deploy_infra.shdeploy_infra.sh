#!/bin/bash

echo "🚀 Starting Minikube..."
minikube start --driver=docker

echo "🛠️ Setting Docker env for Minikube..."
eval $(minikube docker-env)

echo "📦 Building Node.js backend image..."
cd nodejs/redis-node
docker build -t arthurescriou/redis-node:latest .
minikube image load arthurescriou/redis-node:latest
cd ../../

echo "📦 Building React frontend image..."
cd react/redis-react
docker build -t arthurescriou/redis-react:latest .
minikube image load arthurescriou/redis-react:latest
cd ../../

echo "📄 Applying all Kubernetes manifests..."
cd infrastructure
kubectl apply -f redis-master.yaml
kubectl apply -f redis-master-service.yaml
kubectl apply -f redis-replica.yaml
kubectl apply -f redis-replica-service.yaml
kubectl apply -f nodejs-server.yaml
kubectl apply -f nodejs-service.yaml
kubectl apply -f react-frontend.yaml
kubectl apply -f react-service.yaml

echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/nodejs-server
kubectl wait --for=condition=available --timeout=120s deployment/react-frontend

echo "✅ All components deployed!"
minikube service react-service
