# Load environment variables
source scripts/variables.env

# Define Image name and Tag
IMAGE="$ACCOUNT_ID.dkr.ecr.$REGION_NAME.amazonaws.com/$APP_NAME-repository:$VERSION"

# Build the image
podman build -t $IMAGE .

# Get credentials and login to be able to deploy the image to ECR
aws ecr get-login-password --region eu-west-3 | podman login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION_NAME.amazonaws.com

# Publish the docker Image
podman push $ACCOUNT_ID.dkr.ecr.$REGION_NAME.amazonaws.com/$APP_NAME-repository:$VERSION
