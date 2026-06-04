# tests/destroy_blocked.tftest.hcl

# This test is intended to pass its apply/assert phase and then fail when
# `terraform test` performs the automatic cleanup destroy at the end.
# The teardown failure resource depends on the bucket, so cleanup attempts the
# failure resource first and leaves the bucket orphaned in test state.
mock_provider "aws" {
  mock_resource "aws_s3_bucket" {
    defaults = { arn = "arn:aws:s3:::orphaned-bucket-ukeme", id = "orphaned-bucket-ukeme" }
  }
}

run "apply_passes_but_teardown_fails" {
  command = apply

  variables {
    bucket_name      = "orphaned-bucket-ukeme"
    create_bucket    = true
    protected        = false
    fail_on_teardown = true
    teardown_marker  = "destroy-must-fail-after-pass"
  }

  assert {
    condition     = output.bucket_name == "orphaned-bucket-ukeme"
    error_message = "Bucket was not created before the teardown failure resource"
  }

  assert {
    condition     = output.bucket_arn == "arn:aws:s3:::orphaned-bucket-ukeme"
    error_message = "Mocked bucket ARN did not propagate as expected"
  }

  assert {
    condition     = output.teardown_marker == "destroy-must-fail-after-pass"
    error_message = "Teardown failure resource was not created as expected"
  }
}
