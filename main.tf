// main.tf trigger update by changing comments here again
terraform {
  required_version = ">= 1.7.0"
  required_providers { aws = { source = "hashicorp/aws" } }
}
// [test-trigger] failure: orphaned bucket on teardown destroy (module-test)
resource "terraform_data" "destroy_failure" {
  count = var.fail_on_teardown ? 1 : 0

  depends_on = [
    aws_s3_bucket.unprotected,
    aws_s3_bucket.protected,
  ]

  input = var.teardown_marker

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/sh", "-c"]
    command     = "echo 'intentional terraform test teardown failure' >&2; exit 1"
  }
}

# Unprotected variant
resource "aws_s3_bucket" "unprotected" {
  count  = var.create_bucket && !var.protected ? 1 : 0
  bucket = var.bucket_name
  tags   = { Module = "mocked-s3" }
}

# Protected variant (literal prevent_destroy = true)
resource "aws_s3_bucket" "protected" {
  count  = var.create_bucket && var.protected ? 1 : 0
  bucket = var.bucket_name
  lifecycle { prevent_destroy = true }  # must be literal
  tags = { Module = "mocked-s3" }
}

locals {
  bucket_ref = var.protected ? aws_s3_bucket.protected : aws_s3_bucket.unprotected
}

output "bucket_name" { value = length(local.bucket_ref) == 1 ? local.bucket_ref[0].bucket : null }
output "bucket_arn"  { value = length(local.bucket_ref) == 1 ? local.bucket_ref[0].arn    : null }
output "teardown_marker" {
  value = length(terraform_data.destroy_failure) == 1 ? terraform_data.destroy_failure[0].output : null
}
