// variables.tf
variable "bucket_name"   { type = string }
variable "create_bucket" {
  type = bool
default = true
}
variable "protected"     {
  type = bool
  default = false
} # literal control via resource variant
variable "fail_on_teardown" {
  type    = bool
  default = false
}

variable "teardown_marker" {
  type    = string
  default = "teardown-failure"
}