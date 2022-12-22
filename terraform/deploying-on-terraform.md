# Setting up resources on AWS using terraform
## Prerequisites
- Have docker installed (able to run docker compose command in terminal)
- Have terraform (able to run terraform command on terminal)
- An AWS account
- An IAM user with rights to access dynamodb on AWS
- Credentials and config for you IAM user account saved in your local machines .aws directory

## Instructions
### Deploying with terraform
1. Open a terminal at the same location as this file e.g.:
```bash
$ cd path/to/repo/terraform 
```
2. Run the command:
```bash
./create-aws-db.sh
```
3. Login to your aws account you created the IAM user on
4. Check the dynamodb service in the correct region (initially set to us-west-2), see if the airport table was created and initialised with the data.
### Destroying with terraform
1. When you no longer need to use the dynamodb, open a terminal in the terraform/infra directory
2. Run the command `terraform destroy`
3. Check the dynamodb service to check that the dynamodb table was destroyed.