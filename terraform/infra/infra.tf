provider "aws" {
  region = "us-west-2"
}

# dynamodb
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

# roles required by lambda functions
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

# airport lambda function 
resource "aws_lambda_function" "airport_endpoint_function" {
  filename         = "airport_lambda_function.zip"
  function_name    = "airport-endpoints"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "handler_airport.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("airport_lambda_function.zip")
}

resource "aws_api_gateway_rest_api" "airport_apigw" {
  name        = "airport_apigw"
  description = "Airport API Gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_resource" "airports" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  parent_id   = aws_api_gateway_rest_api.airport_apigw.root_resource_id
  path_part   = "airport"
}
resource "aws_api_gateway_method" "readallairports" {
  rest_api_id   = aws_api_gateway_rest_api.airport_apigw.id
  resource_id   = aws_api_gateway_resource.airports.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_resource" "airport" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  parent_id   = aws_api_gateway_resource.airports.id
  path_part   = "{id}"
}
resource "aws_api_gateway_method" "readairport" {
  rest_api_id   = aws_api_gateway_rest_api.airport_apigw.id
  resource_id   = aws_api_gateway_resource.airport.id
  http_method   = "GET"
  authorization = "NONE"
}

# apigateway lambda function integration 
resource "aws_api_gateway_integration" "airport-lambda" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_method.readallairports.resource_id
  http_method = aws_api_gateway_method.readallairports.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = aws_lambda_function.airport_endpoint_function.invoke_arn

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}
resource "aws_lambda_permission" "apigw-airport_endpoint_function" {
  action        = "lambda:InvokeFunction"
  statement_id  = "AllowAirportInvoke"
  function_name = aws_lambda_function.airport_endpoint_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.airport_apigw.execution_arn}/*/*/*"
}
resource "aws_api_gateway_deployment" "productapistageprod" {
  depends_on = [
    aws_api_gateway_integration.airport-lambda,
    aws_api_gateway_integration.airport-lambda-single,
    aws_api_gateway_integration.journey-lambda,
    aws_api_gateway_integration.vehicle-lambda
  ]
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  stage_name  = "prod"
}
resource "aws_api_gateway_integration_response" "myintegrationresponse" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_resource.airports.id
  http_method = aws_api_gateway_method.readallairports.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  } 

  depends_on = [
    aws_api_gateway_integration.airport-lambda,
    aws_api_gateway_method_response.mymethodresponse
  ]
}
resource "aws_api_gateway_method_response" "mymethodresponse" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_resource.airports.id
  http_method = aws_api_gateway_method.readallairports.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.readallairports,
  ]
}

# apigateway lambda function integration 
resource "aws_lambda_function" "journey_endpoint_function" {
  filename         = "journey_lambda_function.zip"
  function_name    = "journey-endpoints"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "handler_journey.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("journey_lambda_function.zip")
}
resource "aws_api_gateway_integration" "airport-lambda-single" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_method.readairport.resource_id
  http_method = aws_api_gateway_method.readairport.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = aws_lambda_function.airport_endpoint_function.invoke_arn

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}
resource "aws_api_gateway_integration_response" "myintegrationresponse-1" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_resource.airport.id
  http_method = aws_api_gateway_method.readairport.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  } 

  depends_on = [
    aws_api_gateway_integration.airport-lambda-single,
    aws_api_gateway_method_response.mymethodresponse-single
  ]
}
resource "aws_api_gateway_method_response" "mymethodresponse-single" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_resource.airport.id
  http_method = aws_api_gateway_method.readairport.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.readairport,
  ]
}

# apigateway journey lambda function integration 
resource "aws_lambda_permission" "apigw-journey_endpoint_function" {
  action        = "lambda:InvokeFunction"
  statement_id  = "AllowJourneyInvoke"
  function_name = aws_lambda_function.journey_endpoint_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.airport_apigw.execution_arn}/*/*/*"
}
resource "aws_api_gateway_resource" "to" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  parent_id   = aws_api_gateway_resource.airport.id
  path_part   = "to"
}
resource "aws_api_gateway_resource" "to-airport-id" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  parent_id   = aws_api_gateway_resource.to.id
  path_part   = "{toId}"
}
resource "aws_api_gateway_method" "journey" {
  rest_api_id   = aws_api_gateway_rest_api.airport_apigw.id
  resource_id   = aws_api_gateway_resource.to-airport-id.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "journey-lambda" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_method.journey.resource_id
  http_method = aws_api_gateway_method.journey.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = aws_lambda_function.journey_endpoint_function.invoke_arn

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}
resource "aws_api_gateway_integration_response" "journey-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_resource.to-airport-id.id
  http_method = aws_api_gateway_method.journey.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  } 

  depends_on = [
    aws_api_gateway_integration.journey-lambda,
    aws_api_gateway_method_response.journey-method-response
  ]
}
resource "aws_api_gateway_method_response" "journey-method-response" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_resource.to-airport-id.id
  http_method = aws_api_gateway_method.journey.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.journey,
  ]
}

# apigateway vehicle lambda function integration 
resource "aws_lambda_function" "vehicle_endpoint_function" {
  filename         = "airport_lambda_function.zip"
  function_name    = "vehicle-endpoints"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "handler_vehicle.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("airport_lambda_function.zip")
}
resource "aws_lambda_permission" "apigw-vehicle_endpoint_function" {
  action        = "lambda:InvokeFunction"
  statement_id  = "AllowVehicleInvoke"
  function_name = aws_lambda_function.vehicle_endpoint_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.airport_apigw.execution_arn}/*/*/*"
}
resource "aws_api_gateway_resource" "vehicle" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  parent_id   = aws_api_gateway_rest_api.airport_apigw.root_resource_id
  path_part   = "vehicle"
}
resource "aws_api_gateway_resource" "no-of-people" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  parent_id   = aws_api_gateway_resource.vehicle.id
  path_part   = "{numberOfPeople}"
}
resource "aws_api_gateway_resource" "distance" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  parent_id   = aws_api_gateway_resource.no-of-people.id
  path_part   = "{distance}"
}
resource "aws_api_gateway_method" "cheapest-vehicle" {
  rest_api_id   = aws_api_gateway_rest_api.airport_apigw.id
  resource_id   = aws_api_gateway_resource.distance.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "vehicle-lambda" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_method.cheapest-vehicle.resource_id
  http_method = aws_api_gateway_method.cheapest-vehicle.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = aws_lambda_function.vehicle_endpoint_function.invoke_arn

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}
resource "aws_api_gateway_integration_response" "vehicle-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_resource.distance.id
  http_method = aws_api_gateway_method.cheapest-vehicle.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  } 

  depends_on = [
    aws_api_gateway_integration.vehicle-lambda,
    aws_api_gateway_method_response.vehicle-method-response
  ]
}
resource "aws_api_gateway_method_response" "vehicle-method-response" {
  rest_api_id = aws_api_gateway_rest_api.airport_apigw.id
  resource_id = aws_api_gateway_resource.distance.id
  http_method = aws_api_gateway_method.cheapest-vehicle.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.cheapest-vehicle,
  ]
}

# outputs url on command line
output "airport_api_invoke_url" {
  value = aws_api_gateway_deployment.productapistageprod.invoke_url
}
