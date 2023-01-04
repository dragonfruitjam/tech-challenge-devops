./package-lambda-functions.sh

cd infra
terraform init
terraform apply -auto-approve

# checks if terraform successfully deployed 
retVal=$?
if [ $retVal -eq 1 ]; then
    exit $retVal
fi

# initiates data in dynamodb created
cd ..
docker build remote-db-initiator/ --tag db-initiator
docker run -v ${HOME}/.aws/:/root/.aws/:ro db-initiator
