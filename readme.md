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