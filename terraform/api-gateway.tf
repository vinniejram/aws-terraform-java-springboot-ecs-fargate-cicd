resource "aws_api_gateway_vpc_link" "cargarage_api_vpc_link" {
  name        = "cargarage_api_vpc_link"
  description = "allows public API Gateway for cargarage to talk to private ALB"
  target_arns = [aws_alb.default.arn]
}

resource "aws_api_gateway_rest_api" "cargarage" {
  description = "Cargarage API Gateway"
  name        = "cargarage"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "parentApiResource" {
  rest_api_id = aws_api_gateway_rest_api.cargarage.id
  parent_id   = aws_api_gateway_rest_api.cargarage.root_resource_id # In this case, the parent id should the gateway root_resource_id.
  path_part   = "api"
}

resource "aws_api_gateway_resource" "cargarageResource" {
  rest_api_id = aws_api_gateway_rest_api.cargarage.id
  parent_id   = aws_api_gateway_resource.parentApiResource.id # In this case, the parent id should be the parent aws_api_gateway_resource id.
  path_part   = "cars"
}

resource "aws_api_gateway_method" "cargarageMethod" {
  rest_api_id   = aws_api_gateway_rest_api.cargarage.id
  resource_id   = aws_api_gateway_resource.cargarageResource.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.carId" = true
  }
}

resource "aws_api_gateway_integration" "cargarageGatewayIntegration" {
  rest_api_id = aws_api_gateway_rest_api.cargarage.id
  resource_id = aws_api_gateway_resource.cargarageResource.id
  http_method = aws_api_gateway_method.cargarageMethod.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${aws_alb.default.dns_name}/api/cars/{id}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.cargarage_api_vpc_link.id
  timeout_milliseconds    = 60000

  cache_key_parameters = ["method.request.path.proxy"]
  request_parameters = {
    "integration.request.path.id" = "method.request.path.carId"
  }
}

resource "aws_api_gateway_method_response" "cargarageMethodResponse" {
  rest_api_id = aws_api_gateway_rest_api.cargarage.id
  resource_id = aws_api_gateway_resource.cargarageResource.id
  http_method = aws_api_gateway_method.cargarageMethod.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "cargarageGatewayIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.cargarage.id
  resource_id = aws_api_gateway_resource.cargarageResource.id
  http_method = aws_api_gateway_method.cargarageMethod.http_method
  status_code = aws_api_gateway_method_response.cargarageMethodResponse.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "cargarageAPIGatewayDeployment" {
  depends_on  = ["aws_api_gateway_integration.cargarageGatewayIntegration"]
  rest_api_id = aws_api_gateway_rest_api.cargarage.id
  stage_name  = "dev"
}

resource "aws_api_gateway_stage" "cargarageAPIGatewayStage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.cargarage.id
  deployment_id = aws_api_gateway_deployment.cargarageAPIGatewayDeployment.id
}
