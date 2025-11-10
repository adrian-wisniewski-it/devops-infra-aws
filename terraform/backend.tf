terraform {
  backend "s3" {
    bucket       = "devops-aws-infra-tfstate-PLACEHOLDER"
    key          = "terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}