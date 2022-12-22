provider "aws" {
  region = "us-west-2"
}

resource "aws_dynamodb_table" "airport" {
  name           = "airport-table"
  hash_key = "id"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "id"
    type = "S"
  }
}