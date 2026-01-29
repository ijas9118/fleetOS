#!/bin/bash

# Deploy FleetOS to EKS

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Deploying FleetOS to EKS${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# Verify kubectl context
echo -e "${YELLOW}Current kubectl context:${NC}"
kubectl config current-context
echo ""

read -p "Is this the correct cluster? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Deployment cancelled."
  exit 1
fi

# Create namespaces
echo -e "${BLUE}Creating namespaces...${NC}"
kubectl apply -f k8s-eks/namespaces.yaml
echo -e "${GREEN}✓ Namespaces created${NC}"
echo ""

# Deploy infrastructure
echo -e "${BLUE}Deploying infrastructure (MongoDB, Redis, Kafka)...${NC}"
kubectl apply -f k8s-eks/infrastructure/
echo -e "${GREEN}✓ Infrastructure deployed${NC}"
echo ""

echo -e "${YELLOW}Waiting for infrastructure to be ready (30s)...${NC}"
sleep 30

# Deploy Kong Gateway
echo -e "${BLUE}Deploying Kong API Gateway...${NC}"
kubectl apply -f k8s-eks/gateway/
echo -e "${GREEN}✓ Kong deployed${NC}"
echo ""

echo -e "${YELLOW}Waiting for Kong to be ready (15s)...${NC}"
sleep 15

# Deploy core services
echo -e "${BLUE}Deploying core services...${NC}"
kubectl apply -f k8s-eks/core-services/
echo -e "${GREEN}✓ Core services deployed${NC}"
echo ""

# Show deployment status
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Deployment Status${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

echo -e "${YELLOW}Infrastructure Pods:${NC}"
kubectl get pods -n infrastructure
echo ""

echo -e "${YELLOW}Core Services Pods:${NC}"
kubectl get pods -n core-services
echo ""

echo -e "${YELLOW}Gateway Pods:${NC}"
kubectl get pods -n gateway
echo ""

echo -e "${YELLOW}Kong LoadBalancer URL:${NC}"
kubectl get svc -n gateway kong
echo ""

echo -e "${GREEN}Deployment complete!${NC}"
echo ""
echo -e "${YELLOW}To get Kong URL:${NC}"
echo "kubectl get svc -n gateway kong -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo ""
echo -e "${YELLOW}To watch pod status:${NC}"
echo "kubectl get pods -A -w"
