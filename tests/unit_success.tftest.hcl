# tests/unit_success.tftest.hcl
mock_provider "aws" {
  mock_resource "aws_s3_bucket" {
    defaults = { arn = "arn:aws:s3:::example-bucket", id = "example-bucket" }
  }
}

run "apply_and_assert_unprotected" {
  command = apply

  variables {
    bucket_name    = "test-bucket-ukeme"
    protected      = false
  }

  assert {
    condition     = output.bucket_name == "test-bucket-ukeme"
    error_message = "Bucket name mismatch"
  }

  assert {
    condition     = output.bucket_arn == "arn:aws:s3:::example-bucket"
    error_message = "Mocked ARN didn't take effect"
  }
}