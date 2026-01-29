#!/bin/bash

# Update image references in k8s-eks manifests with ECR registry

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Updating image references in k8s-eks manifests...${NC}"
echo ""

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-ap-south-1}
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo -e "${YELLOW}ECR Registry:${NC} $ECR_REGISTRY"
echo ""

# Update all service YAML files
for file in k8s-eks/core-services/*.yaml; do
  echo -e "${YELLOW}Updating:${NC} $file"
  sed -i '' "s|REPLACE_WITH_ECR_REGISTRY|${ECR_REGISTRY}|g" "$file"
done

echo ""
echo -e "${GREEN}✓ All manifests updated!${NC}"
echo ""
echo -e "${YELLOW}Next step:${NC} Deploy to EKS"
echo "kubectl apply -f k8s-eks/"
