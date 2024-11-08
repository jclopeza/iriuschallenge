source scripts/variables.env

aws apprunner create-service \
  --service-name $APP_NAME \
  --source-configuration "AuthenticationConfiguration={AccessRoleArn=arn:aws:iam::$ACCOUNT_ID:role/$APP_NAME-role},ImageRepository={ImageIdentifier=$ACCOUNT_ID.dkr.ecr.$REGION_NAME.amazonaws.com/$APP_NAME-repository:$VERSION,ImageRepositoryType=ECR,ImageConfiguration={Port=8000,RuntimeEnvironmentSecrets={AWS_ACCESS_KEY_ID=arn:aws:ssm:$REGION_NAME:$ACCOUNT_ID:parameter/dev/irius/aws_access_key_id,AWS_SECRET_ACCESS_KEY=arn:aws:ssm:$REGION_NAME:$ACCOUNT_ID:parameter/dev/irius/aws_secret_access_key,AWS_REGION=arn:aws:ssm:$REGION_NAME:$ACCOUNT_ID:parameter/dev/irius/region_name}}}" \
  --instance-configuration "InstanceRoleArn=arn:aws:iam::$ACCOUNT_ID:role/$APP_NAME-role"
