docker build remote-db-initiator/ --tag db-initiator
cd ../lambda ; zip -r ../terraform/infra/lambda_function.zip . ; cd ../terraform

cd infra
terraform init
terraform apply -auto-approve

retVal=$?
if [ $retVal -eq 1 ]; then
    exit $retVal
fi

docker run -v ${HOME}/.aws/:/root/.aws/:ro db-initiator
