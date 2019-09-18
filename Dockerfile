FROM python:alpine

LABEL "com.github.actions.name"="lambda-github-actions"
LABEL "com.github.actions.description"="Deploy Lambda through GitHub Actions"
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="purple"

RUN pip3 install awscli --upgrade --user\
    aws --version

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
