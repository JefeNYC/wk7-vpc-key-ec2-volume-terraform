terraform {
  backend "s3" {
    bucket       = "wk7-jefe-terraform-bucket"
    key          = "week7/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = false
  }
}
