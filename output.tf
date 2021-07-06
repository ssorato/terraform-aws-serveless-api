output "api-url-dev" {
  description = "API dev url"
  value       = aws_api_gateway_stage.devStage.invoke_url
}

output "api-url-prd" {
  description = "API prd url"
  value       = aws_api_gateway_stage.prdStage.invoke_url
}