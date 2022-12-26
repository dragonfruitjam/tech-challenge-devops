provider "aws" {
  region = "us-west-2"
}

resource "aws_dynamodb_table" "airport" {
  name           = "airport"
  hash_key = "id"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "lambda_dynamodb_policy"
  role = aws_iam_role.lambda_exec_role.id
  policy = <<EOF
{  
  "Version": "2012-10-17",
  "Statement":[{
    "Effect": "Allow",
    "Action": [
     "dynamodb:BatchGetItem",
     "dynamodb:GetItem",
     "dynamodb:Query",
     "dynamodb:Scan",
     "dynamodb:BatchWriteItem",
     "dynamodb:PutItem",
     "dynamodb:UpdateItem"
    ],
    
    "Resource": "${aws_dynamodb_table.airport.arn}"
   }
  ]
}
EOF
}

resource "aws_lambda_function" "example_function" {
  filename         = "lambda_function.zip"
  function_name    = "airport-endpoints"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda.handler_airport.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda_function.zip")
  
  environment {
    variables = {
      TABLE_NAME = "example-table"
    }
  }
}
