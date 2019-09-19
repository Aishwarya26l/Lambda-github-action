#!/bin/sh -l

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
export APINAME="$LAMBDA_FUNC_NAME-API"

aws cloudformation validate-template \
    --template-body file://template.yaml

aws cloudformation deploy \
    --stack-name ${LAMBDA_FUNC_NAME} \
    --template-file template.yaml \
    --capabilities CAPABILITY_IAM \
    --region ${AWS_DEFAULT_REGION} \
    --parameter-overrides ParameterKey=LambdaFuncName,ParameterValue=${LAMBDA_FUNC_NAME}
    
exit 0 