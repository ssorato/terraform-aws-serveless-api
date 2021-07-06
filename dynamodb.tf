module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name        = "Temperatures"
  hash_key    = "eventDateTime"
  range_key   = "deviceId"

  attributes  = [
    {
      name = "eventDateTime"
      type = "S"
    },
    {
      name = "deviceId"
      type = "S"
    }
  ]

  tags = var.common_tag
}