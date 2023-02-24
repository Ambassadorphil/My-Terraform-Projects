# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket    = "terra2tu"
    key       = "path/to/my/key"
    region    = "us-east-1"
  }
}
