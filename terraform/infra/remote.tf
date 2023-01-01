terraform {
  backend "s3" {
    encrypt  = true
    bucket   = "airport-api-tf"
    key      = "infra.tfstate"
    region   = "us-west-2"
    dynamodb_table = "airport-api-tflock"
  }
}
