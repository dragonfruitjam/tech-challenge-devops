docker build remote-db-initiator/ --tag db-initiator
cd infra
terraform init
terraform apply -auto-approve
docker run -v ${HOME}/.aws/:/root/.aws/:ro db-initiator