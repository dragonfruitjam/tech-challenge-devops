docker build remote-db-initiator/ --tag db-initiator
cd ../lambda ; zip -r ../terraform/infra/lambda_function.zip . ; cd ../terraform

cd infra
terraform init
terraform apply -auto-approve
rm lambda_function.zip
docker run -v ${HOME}/.aws/:/root/.aws/:ro db-initiator
