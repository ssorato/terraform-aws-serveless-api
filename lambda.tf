module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  for_each = {
    post = {
      source_path   = "./insertTemperature.py"
      handler       = "insertTemperature.lambda_handler"
      policy_action = "\"dynamodb:PutItem\""
    },
    get = {
      source_path   = "./getTemperature.py"
      handler       = "getTemperature.lambda_handler"
      policy_action = "\"dynamodb:Scan\""
    }
  }

  function_name       = "${var.lab_name}-lambda-${each.key}"
  description         = "A lambda function to manage the ${upper(each.key)} action"
  handler             = each.value.handler
  runtime             = "python3.7"

  source_path         = each.value.source_path

  role_name           = "LambdaDynamoDB${each.key}"
  attach_policy_json  = true
  policy_json         = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [ ${each.value.policy_action} ],
            "Resource": "${module.dynamodb_table.dynamodb_table_arn}"
        }
    ]
}
EOF

  create_current_version_allowed_triggers   = false
  create_unqualified_alias_allowed_triggers = false
  cloudwatch_logs_retention_in_days         = 1
  cloudwatch_logs_tags                      = var.common_tag
  tags                                      = var.common_tag
}

resource "aws_lambda_permission" "apiPermission" {
  for_each      = toset( ["get", "post"] )
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function[each.key].lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${upper(each.key)}/"
  depends_on    = [ aws_api_gateway_rest_api.api ]
}
