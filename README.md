# terraform-ukmocker-test-aws-mocks

`tests/unit_success.tftest.hcl` covers the normal mocked apply path and uses the
unprotected resource variant so Terraform test cleanup can succeed.

`tests/destroy_blocked.tftest.hcl` covers the teardown failure scenario. The run
itself succeeds and its assertion passes, but the test framework's automatic
cleanup destroy should fail afterward because a `terraform_data` resource has a
destroy-time `local-exec` provisioner that exits with status `1`. That
`terraform_data` resource explicitly depends on the mocked bucket resources, so
Terraform attempts to destroy the failure resource first during cleanup and the
bucket remains undeleted when teardown aborts.