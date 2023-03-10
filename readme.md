# Tech DevOps Challenge (Devloper Guide)
## Deploying local database and api gateway
### Prerequisites:  
- Have docker installed with `docker compose` command
### Instructions
1. Open a terminal located at the root of this repo
2. Run the command docker compose up
3. After the containers have finished building and are running you can test they have been deployed succesfully by running the command
```bash
curl http://localhost:8080/airport
```

## Running unit tests
### Instructions
1. Follow the steps to deploy a local database and api gateway on your machine
2. In a new terminal go to the test directory on this repo
```bash
$ cd path/to/repo/tests
```
3. Run the command:
```
$ python3 test-endpoint.py
```

## CI/CD
This repository is implemented to follow a CI/CD workflow.
When a pull request is made with the main branch as the target, the code will be tested. If the tests pass, the code can be used to depoy resources on aws.

To deploy the infrastructure, simply merge the pull request into main.

You can see the progress of the deployment in the following page: https://github.com/dragonfruitjam/tech-challenge-devops/actions/workflows/airport-api-cd.yml.

At the end of the `Deploy aws resources` job, the url generated to access the api gateway is output at the bottom. e.g.
```
airport_api_invoke_url = "https://url/to/api/gateway"
```
The github link above can also be used to manually deploy the aws resources after they have been manually destroyed

### Destroying AWS resources
To destroy the resources related to this project, you can run the job on Github (https://github.com/dragonfruitjam/tech-challenge-devops/actions):  
1. Select the `Airport API Terraform Destroy` workflow
2. Click `Run workflow` button
3. Select the branch as `main` and click `Run workflow` to start the job to destroy AWS resources
4. Wait for the job to complete
5. Check AWS to see if the resources have been destroyed

## Future work
1. Ask client how booking fee should work if miles traveled is zero
2. Make airport queries case insensitive
3. Implement open api lambda integration
4. Implement logging so error messages are not passed back to users
5. Move Github repo to organisational account to implement branch protection