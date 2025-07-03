#!/bin/bash

# Script to handle API Gateway method conflicts
# This script helps identify and optionally delete existing API Gateway methods

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}API Gateway Conflict Resolution Script${NC}"
echo "=============================================="

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

# Get all resources
echo -e "${GREEN}Getting API Gateway resources...${NC}"
RESOURCES=$(aws apigateway get-resources --rest-api-id "$API_ID" --output json)

# Function to check if a method exists
check_method_exists() {
    local resource_id=$1
    local http_method=$2
    
    aws apigateway get-method \
        --rest-api-id "$API_ID" \
        --resource-id "$resource_id" \
        --http-method "$http_method" \
        --output text > /dev/null 2>&1
}

# Function to delete a method
delete_method() {
    local resource_id=$1
    local http_method=$2
    
    echo -e "${YELLOW}Deleting ${http_method} method from resource ${resource_id}${NC}"
    aws apigateway delete-method \
        --rest-api-id "$API_ID" \
        --resource-id "$resource_id" \
        --http-method "$http_method"
    echo -e "${GREEN}✓ Deleted ${http_method} method${NC}"
}

# Process each resource
echo -e "${GREEN}Checking existing methods...${NC}"
echo ""

# Parse resources and check methods
echo "$RESOURCES" | jq -r '.items[] | "\(.id) \(.pathPart // .path)"' | while read -r resource_id path_part; do
    if [ "$path_part" = "api" ]; then
        echo -e "${GREEN}Found api resource (ID: ${resource_id})${NC}"
        
        # Check for OPTIONS method
        if check_method_exists "$resource_id" "OPTIONS"; then
            echo -e "${YELLOW}OPTIONS method exists on main_api${NC}"
            read -p "Do you want to delete the OPTIONS method? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                delete_method "$resource_id" "OPTIONS"
            fi
        fi
        
        # Check for GET method
        if check_method_exists "$resource_id" "GET"; then
            echo -e "${YELLOW}GET method exists on main_api${NC}"
            read -p "Do you want to delete the GET method? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                delete_method "$resource_id" "GET"
            fi
        fi
        
        # Check for POST method
        if check_method_exists "$resource_id" "POST"; then
            echo -e "${YELLOW}POST method exists on main_api${NC}"
            read -p "Do you want to delete the POST method? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                delete_method "$resource_id" "POST"
            fi
        fi
    fi
done

echo ""
echo -e "${GREEN}Checking Lambda permissions...${NC}"

# Check for existing Lambda permissions
FUNCTION_NAME="np-managment-main-api"
PERMISSION_ID="AllowExecutionFromAPIGateway-main_api"

# Try to get the permission
if aws lambda get-policy --function-name "$FUNCTION_NAME" --output text 2>/dev/null | grep -q "$PERMISSION_ID"; then
    echo -e "${YELLOW}Lambda permission ${PERMISSION_ID} already exists${NC}"
    read -p "Do you want to remove this permission? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Removing Lambda permission...${NC}"
        aws lambda remove-permission \
            --function-name "$FUNCTION_NAME" \
            --statement-id "$PERMISSION_ID"
        echo -e "${GREEN}✓ Removed Lambda permission${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Conflict resolution complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Run: terraform plan"
echo "2. Run: terraform apply"
echo ""
echo -e "${YELLOW}Note:${NC} If you still get conflicts, you may need to:"
echo "- Use a different API Gateway name"
echo "- Use a different stage name"
echo "- Import existing resources into Terraform state" 