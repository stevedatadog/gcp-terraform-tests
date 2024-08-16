#!/bin/bash

# Ensure script is run with required arguments
# If not provided, an environment variable $GCR_PROJECT_ID will be used 
if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <ECR_IMAGE_PATH> [GCR_PROJECT_ID] [GCR_IMAGE_NAME]"
    echo "Example: $0 public.ecr.aws/x2b9z2t7/ddtraining/advertisements-fixed:2.2.0 [my-gcp-project] [advertisements-fixed:2.2.0]"
    exit 1
fi

# Set variables from script arguments
ECR_IMAGE_PATH=$1
GCR_PROJECT_ID=${2:-$GCP_PROJECT_ID}

# Ensure GCR_PROJECT_ID is set
if [ -z "$GCR_PROJECT_ID" ]; then
    echo "Error: GCP_PROJECT_ID environment variable or GCR_PROJECT_ID argument must be set."
    exit 1
fi

# Derive the image name and tag from ECR_IMAGE_PATH if GCR_IMAGE_NAME is not provided
if [ -z "$3" ]; then
    ECR_IMAGE_NAME_WITH_TAG=$(basename $ECR_IMAGE_PATH)
    GCR_IMAGE_NAME=$ECR_IMAGE_NAME_WITH_TAG
else
    GCR_IMAGE_NAME=$3
fi

# Full GCR image path
GCR_IMAGE_PATH="gcr.io/$GCR_PROJECT_ID/$GCR_IMAGE_NAME"

# Authenticate Docker to AWS ECR (private repo).
# echo "Authenticating Docker to AWS ECR..."
# aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws

# Pull the Docker image from ECR
echo "Pulling Docker image from ECR: $ECR_IMAGE_PATH"
docker pull $ECR_IMAGE_PATH

# Tag the image for GCR
echo "Tagging image for GCR: $GCR_IMAGE_PATH"
docker tag $ECR_IMAGE_PATH $GCR_IMAGE_PATH

# Authenticate Docker to GCR
echo "Authenticating Docker to GCR..."
gcloud auth configure-docker

# Push the image to GCR
echo "Pushing image to GCR: $GCR_IMAGE_PATH"
docker push $GCR_IMAGE_PATH

echo "Image successfully pushed to GCR: $GCR_IMAGE_PATH"

