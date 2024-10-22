terraform {
  backend "s3" {
    bucket = "terraform-workplaces"
    key    = "us/cf-s3/terraform.tfstate"
    region = "us-east-1"
  }
}