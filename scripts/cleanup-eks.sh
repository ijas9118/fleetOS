#!/bin/bash

# FleetOS EKS Cleanup Script
# This script removes all deployed resources from the EKS cluster

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}======================================${NC}"
echo -e "${RED}FleetOS EKS Cleanup${NC}"
echo -e "${RED}======================================${NC}"
echo ""
echo -e "${YELLOW}This will delete:${NC}"
echo "  - All microservices (auth, fleet, inventory, shipment, notification)"
echo "  - Kong API Gateway"
echo "  - Infrastructure (MongoDB, Redis, Kafka)"
echo "  - All namespaces"
echo ""
read -p "Are you sure you want to continue? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]
then
    echo "Cleanup cancelled."
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 1: Deleting core services...${NC}"
kubectl delete -f k8s-eks/core-services/ --ignore-not-found=true
echo -e "${GREEN}✓ Core services deleted${NC}"

echo ""
echo -e "${YELLOW}Step 2: Deleting Kong API Gateway...${NC}"
kubectl delete -f k8s-eks/gateway/ --ignore-not-found=true
echo -e "${GREEN}✓ Gateway deleted${NC}"

echo ""
echo -e "${YELLOW}Step 3: Deleting infrastructure...${NC}"
kubectl delete -f k8s-eks/infrastructure/ --ignore-not-found=true
echo -e "${GREEN}✓ Infrastructure deleted${NC}"

echo ""
echo -e "${YELLOW}Step 4: Deleting namespaces...${NC}"
kubectl delete -f k8s-eks/namespaces.yaml --ignore-not-found=true
echo -e "${GREEN}✓ Namespaces deleted${NC}"

echo ""
echo -e "${YELLOW}Step 5: Waiting for LoadBalancer cleanup (if any)...${NC}"
sleep 10

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Cleanup Complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${YELLOW}Remaining resources to check:${NC}"
kubectl get all -A | grep -E "(core-services|infrastructure|gateway)" || echo "No application resources found ✓"
echo ""
echo -e "${YELLOW}Optional: Clean up ECR Docker images${NC}"
echo ""
read -p "Do you want to delete ECR repositories and images? (yes/no): " -r
echo
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]
then
    echo -e "${YELLOW}Deleting ECR repositories...${NC}"
    aws ecr delete-repository --repository-name fleetos/auth-service --region ap-south-1 --force || echo "Repository not found or already deleted"
    aws ecr delete-repository --repository-name fleetos/fleet-service --region ap-south-1 --force || echo "Repository not found or already deleted"
    aws ecr delete-repository --repository-name fleetos/inventory-service --region ap-south-1 --force || echo "Repository not found or already deleted"
    aws ecr delete-repository --repository-name fleetos/shipment-service --region ap-south-1 --force || echo "Repository not found or already deleted"
    aws ecr delete-repository --repository-name fleetos/notification-service --region ap-south-1 --force || echo "Repository not found or already deleted"
    echo -e "${GREEN}✓ ECR repositories deleted${NC}"
else
    echo "ECR repositories kept. To delete later, run:"
    echo "  aws ecr delete-repository --repository-name fleetos/auth-service --region ap-south-1 --force"
    echo "  (repeat for other services)"
fi
echo ""
echo -e "${YELLOW}To delete the entire EKS cluster:${NC}"
echo "  eksctl delete cluster --name fleetos-demo --region ap-south-1"
echo ""
echo -e "${GREEN}Cleanup complete!${NC}"
echo ""
