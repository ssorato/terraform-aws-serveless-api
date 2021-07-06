resource "aws_api_gateway_rest_api" "api" {
  name        = "temperature-api"
  description = "A temperature REST API Gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "methodGet" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integrationGet" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_rest_api.api.root_resource_id
  http_method             = aws_api_gateway_method.methodGet.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda_function["get"].lambda_function_invoke_arn
}

resource "aws_api_gateway_method_response" "responseGet" {
  rest_api_id     = aws_api_gateway_rest_api.api.id
  resource_id     = aws_api_gateway_rest_api.api.root_resource_id
  http_method     = aws_api_gateway_method.methodGet.http_method
  status_code     = "200"
  response_models = {
    "application/json" = "Empty"
  } 
}

resource "aws_api_gateway_integration_response" "integrationResponseGet" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.methodGet.http_method
  status_code = aws_api_gateway_method_response.responseGet.status_code
  depends_on = [
    aws_api_gateway_integration.integrationGet
  ]
}

resource "aws_api_gateway_method" "methodPost" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integrationPost" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_rest_api.api.root_resource_id
  http_method             = aws_api_gateway_method.methodPost.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda_function["post"].lambda_function_invoke_arn
}

resource "aws_api_gateway_method_response" "responsePost" {
  rest_api_id     = aws_api_gateway_rest_api.api.id
  resource_id     = aws_api_gateway_rest_api.api.root_resource_id
  http_method     = aws_api_gateway_method.methodPost.http_method
  status_code     = "200"
  response_models = {
    "application/json" = "Empty"
  } 
}

resource "aws_api_gateway_integration_response" "integrationResponsePost" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.methodPost.http_method
  status_code = aws_api_gateway_method_response.responsePost.status_code
  depends_on = [
    aws_api_gateway_integration.integrationPost
  ]
}

resource "aws_api_gateway_deployment" "theDeploy" {
  depends_on = [
    aws_api_gateway_integration.integrationGet,
    aws_api_gateway_integration.integrationPost,
    aws_lambda_permission.apiPermission
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  #
  # Not sure if this resolves the error "No match for output mapping and no default output mapping configured"
  # with the dependency "aws_lambda_permission.apiPermission" 
  # 
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "devStage" {
  deployment_id = aws_api_gateway_deployment.theDeploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}

resource "aws_api_gateway_stage" "prdStage" {
  deployment_id = aws_api_gateway_deployment.theDeploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prd"
}
