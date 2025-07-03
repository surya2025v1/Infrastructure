#!/bin/bash

# Script to clean up API Gateway stages
# This script helps identify and optionally delete existing API Gateway stages

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}API Gateway Stage Cleanup Script${NC}"
echo "======================================"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo -e "${RED}Error: AWS CLI is not configured or credentials are invalid${NC}"
    echo "Please run: aws configure"
    exit 1
fi

# Get API Gateway ID
echo -e "${GREEN}Searching for API Gateway: temple-project-api-main${NC}"
API_ID=$(aws apigateway get-rest-apis --query 'items[?name==`temple-project-api-main`].id' --output text)

if [ -z "$API_ID" ] || [ "$API_ID" = "None" ]; then
    echo -e "${RED}Error: API Gateway 'temple-project-api-main' not found${NC}"
    exit 1
fi

echo -e "${GREEN}Found API Gateway ID: ${API_ID}${NC}"

# Get all stages
echo -e "${GREEN}Getting API Gateway stages...${NC}"
STAGES=$(aws apigateway get-stages --rest-api-id "$API_ID" --output json)

# Function to delete a stage
delete_stage() {
    local stage_name=$1
    
    echo -e "${YELLOW}Deleting stage: ${stage_name}${NC}"
    aws apigateway delete-stage \
        --rest-api-id "$API_ID" \
        --stage-name "$stage_name"
    echo -e "${GREEN}✓ Deleted stage: ${stage_name}${NC}"
}

# Process each stage
echo -e "${GREEN}Checking existing stages...${NC}"
echo ""

# Parse stages and check for conflicts
echo "$STAGES" | jq -r '.item[] | .stageName' | while read -r stage_name; do
    if [ "$stage_name" = "v0703251235" ]; then
        echo -e "${GREEN}Found conflicting stage: ${stage_name}${NC}"
        read -p "Do you want to delete this stage? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            delete_stage "$stage_name"
        fi
    else
        echo -e "${YELLOW}Found other stage: ${stage_name}${NC}"
        read -p "Do you want to delete this stage? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            delete_stage "$stage_name"
        fi
    fi
done

echo ""
echo -e "${GREEN}Stage cleanup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Run: terraform plan"
echo "2. Run: terraform apply"
echo ""
echo -e "${YELLOW}Note:${NC} If you still get conflicts, you may need to:"
echo "- Use a different stage name"
echo "- Import existing resources into Terraform state" 