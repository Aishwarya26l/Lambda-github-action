#!/bin/sh -l

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
export APINAME="$LAMBDA_FUNC_NAME-API"
export OVERLAY_S3URL="s3://${BUCKET_NAME}/${LAMBDA_FUNC_NAME}/lambda-deploy.tgz"


rm -f lambda-deploy.zip
tar -czvf lambda-deploy-overlay.tgz ./
aws s3 cp --acl public-read lambda-deploy-overlay.tgz "$OVERLAY_S3URL"
zip -r lambda-deploy.zip ./

aws cloudformation validate-template \
    --template-body file://template.yaml

aws cloudformation package \
   --template-file template.yaml \
   --output-template-file packaged.yaml \
   --s3-bucket "${BUCKET_NAME}"

cat packaged.yaml

aws cloudformation deploy \
    --stack-name ${LAMBDA_FUNC_NAME} \
    --template-file template.yaml \
    --capabilities CAPABILITY_IAM \
    --region ${AWS_DEFAULT_REGION} \
    --parameter-overrides ParameterKey=LambdaFuncName,ParameterValue=${LAMBDA_FUNC_NAME}
    
exit 0 