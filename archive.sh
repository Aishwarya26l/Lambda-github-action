#!/bin/sh -l

sh -c "echo Hello world my name is $MY_NAME"
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
export APINAME="$LAMBDA_FUNC_NAME-API"

# Zip Lambda Contents
zip -qr lambdaFunc.zip .

if aws lambda get-function --function-name $LAMBDA_FUNC_NAME
    then
        if aws lambda update-function-code \
            --function-name $LAMBDA_FUNC_NAME \
            --zip-file fileb://lambdaFunc.zip 
            then 
                sh -c "echo Successfully Deployed - $LAMBDA_FUNC_NAME"
            else
                sh -c "echo Error while deploying - $LAMBDA_FUNC_NAME"
                exit 1
        fi
    else
        if aws lambda create-function --function-name $LAMBDA_FUNC_NAME \
            --zip-file fileb://lambdaFunc.zip  \
            --handler $LAMBDA_HANDLER \
            --runtime $LAMBDA_RUNTIME \
            --role $LAMBDA_BASIC_EXEC_ARN
            then 
                sh -c "echo Successfully Created - $LAMBDA_FUNC_NAME"
            else
                sh -c "echo Error while creating - $LAMBDA_FUNC_NAME"
                exit 1
        fi
        
fi

export LAMBDAARN=$(aws lambda list-functions --query "Functions[?FunctionName==\`${LAMBDA_FUNC_NAME}\`].FunctionArn" --output text --region ${AWS_DEFAULT_REGION})

# API-Gateway settings

# Create rest-api
aws apigateway create-rest-api --name "${APINAME}" \
    --description "Api for ${LAMBDA_FUNC_NAME}" \
    --region ${AWS_DEFAULT_REGION}
export APIID=$(aws apigateway get-rest-apis --query "items[?name==\`${APINAME}\`].id" --output text --region ${AWS_DEFAULT_REGION})
export PARENTRESOURCEID=$(aws apigateway get-resources --rest-api-id ${APIID} --query 'items[?path==`/`].id' --output text --region ${AWS_DEFAULT_REGION})

# Create a proxy resource
aws apigateway create-resource \
    --rest-api-id ${APIID} \
    --parent-id ${PARENTRESOURCEID} \
    --path-part {proxy+} \
    --region ${AWS_DEFAULT_REGION}
export RESOURCEID=$(aws apigateway get-resources --rest-api-id ${APIID} --query 'items[?path==`/{proxy+}`].id' --output text --region ${AWS_DEFAULT_REGION})

aws apigateway put-method --rest-api-id ${APIID} \
       --resource-id ${RESOURCEID} \
       --http-method ANY \
       --authorization-type "NONE" \
       --region ${AWS_DEFAULT_REGION}

aws apigateway put-integration \
        --region ${AWS_DEFAULT_REGION} \
        --rest-api-id ${APIID} \
        --resource-id ${RESOURCEID} \
        --http-method ANY \
        --type AWS_PROXY \
        --integration-http-method POST \
        --uri arn:aws:apigateway:${AWS_DEFAULT_REGION}:lambda:path/2015-03-31/functions/${LAMBDAARN}/invocations \

aws apigateway create-deployment \
    --rest-api-id ${APIID} \
    --stage-name default

    
exit 0