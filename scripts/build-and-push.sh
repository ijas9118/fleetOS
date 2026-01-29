#!/bin/bash

# FleetOS EKS Docker Build & Push Script
# This script builds all microservices and pushes them to ECR

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}FleetOS Docker Build & Push to ECR${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-ap-south-1}
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo -e "${YELLOW}AWS Account ID:${NC} $AWS_ACCOUNT_ID"
echo -e "${YELLOW}AWS Region:${NC} $AWS_REGION"
echo -e "${YELLOW}ECR Registry:${NC} $ECR_REGISTRY"
echo ""

# Login to ECR
echo -e "${YELLOW}Logging in to ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
echo -e "${GREEN}✓ ECR login successful${NC}"
echo ""

# Services to build
services=(
  "auth-service"
  "fleet-service"
  "inventory-service"
  "shipment-service"
  "notification-service"
)

# Build and push each service
for service in "${services[@]}"; do
  echo -e "${YELLOW}===========================================${NC}"
  echo -e "${YELLOW}Building: fleet-os-${service}${NC}"
  echo -e "${YELLOW}===========================================${NC}"
  
  # Build the image for AMD64 architecture (EKS nodes are x86_64)
  echo -e "${YELLOW}Building Docker image for AMD64...${NC}"
  docker build \
    --platform linux/amd64 \
    -t fleetos/${service}:latest \
    -f fleet-os-${service}/Dockerfile \
    fleet-os-${service}/
  
  echo -e "${GREEN}✓ Build completed${NC}"
  
  # Tag for ECR
  echo -e "${YELLOW}Tagging image...${NC}"
  docker tag fleetos/${service}:latest ${ECR_REGISTRY}/fleetos/${service}:latest
  echo -e "${GREEN}✓ Image tagged${NC}"
  
  # Push to ECR
  echo -e "${YELLOW}Pushing to ECR...${NC}"
  docker push ${ECR_REGISTRY}/fleetos/${service}:latest
  echo -e "${GREEN}✓ Push completed${NC}"
  echo ""
done

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}All images built and pushed!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update k8s-eks manifests with ECR registry URL"
echo "2. Run: ./scripts/update-image-refs.sh"
echo "3. Deploy to EKS: kubectl apply -f k8s-eks/"
echo ""
