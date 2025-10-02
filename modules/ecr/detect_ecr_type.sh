#!/bin/bash

# Script to detect ECR registry type and extract information
# Usage: detect_ecr_type.sh <ecr_registry_url>

set -e

ECR_REGISTRY="$1"

if [ -z "$ECR_REGISTRY" ]; then
  echo '{}'
  exit 1
fi

# Initialize JSON object
json_output='{}'

# Detect if it's AWS Public ECR
if [[ "$ECR_REGISTRY" == *"public.ecr.aws"* ]]; then
  # Public ECR Example: public.ecr.aws/x7o9n0b1
  json_output=$(echo "$json_output" | jq --arg val "true" '.is_public_ecr = $val')
  json_output=$(echo "$json_output" | jq --arg val "$ECR_REGISTRY" '.registry_id = $val')
  json_output=$(echo "$json_output" | jq '.aws_account = "public"')
  json_output=$(echo "$json_output" | jq '.aws_region = "us-east-1"')
  
  # Extract repository name - assume it's after the last slash
  repo_name=$(echo "$ECR_REGISTRY" | sed 's|.*/||' | tr '-' '_' | tr '[:upper:]' '[:lower:]')
  json_output=$(echo "$json_output" | jq --arg val "$repo_name" '.repo_name = $val')

# Detect if it's Private ECR
elif [[ "$ECR_REGISTRY" == *.dkr.ecr.*.amazonaws.com ]]; then
  # Private ECR Example: 123456789012.dkr.ecr.us-east-1.amazonaws.com
  json_output=$(echo "$json_output" | jq --arg val "false" '.is_public_ecr = $val')
  json_output=$(echo "$json_output" | jq --arg val "$ECR_REGISTRY" '.registry_id = $val')
  
  # Extract account ID and region
  account_id=$(echo "$ECR_REGISTRY" | sed -n 's/\([0-9]*\)\.dkr\.ecr\.\([^.]*\)\.amazonaws\.com/\1/p')
  aws_region=$(echo "$ECR_REGISTRY" | sed -n 's/\([0-9]*\)\.dkr\.ecr\.\([^.]*\)\.amazonaws\.com/\2/p')
  
  json_output=$(echo "$json_output" | jq --arg val "$account_id" '.aws_account = $val')
  
  # Set repository name from account ID (convert to suitable format)
  repo_name=$(echo "$account_id" | tr '-' '_' | tr '[:upper:]' '[:lower:]')
  json_output=$(echo "$json_output" | jq --arg val "$repo_name" '.repo_name = $val')
  
  json_output=$(echo "$json_output" | jq --arg val "$aws_region" '.aws_region = $val')

# Fallback for unknown format
else
  json_output=$(echo "$json_output" | jq --arg val "false" '.is_public_ecr = $val')
  json_output=$(echo "$json_output" | jq '.registry_id = null')
  json_output=$(echo "$json_output" | jq '.aws_account = null')
  json_output=$(echo "$json_output" | jq '.aws_region = null')
  json_output=$(echo "$json_output" | jq '.repo_name = "unknown"')
fi

echo "$json_output"
