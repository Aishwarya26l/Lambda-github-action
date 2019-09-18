#!/bin/sh -l

sh -c "echo Hello world my name is $MY_NAME"
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

# Zip Lambda Contents
zip -qr lambdaFunc.zip .

if aws lambda get-function --function-name $LAMBDA_FUNC_NAME
    then
        if aws lambda create-function --function-name $LAMBDA_FUNC_NAME \
            --zip-file fileb://lambdaFunc.zip  \
            --handler index.handler \
            --runtime nodejs10.x \
            --role $LAMBDA_BASIC_EXEC_ARN
            then 
                sh -c "echo Successfully Created - $LAMBDA_FUNC_NAME"
            else
                sh -c "echo Error while creating - $LAMBDA_FUNC_NAME"
        fi
    else
        then 
            if aws lambda update-function-code \
                --function-name $LAMBDA_FUNC_NAME \
                --zip-file fileb://lambdaFunc.zip 
                then 
                    sh -c "echo Successfully Deployed - $LAMBDA_FUNC_NAME"
                else
                    sh -c "echo Error while deploying - $LAMBDA_FUNC_NAME"
            fi
fi