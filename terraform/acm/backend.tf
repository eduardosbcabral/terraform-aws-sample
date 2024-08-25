terraform {
  backend "s3" {
    bucket = "terraform-workplaces"
    key    = "us/acm/terraform.tfstate"
    region = "us-east-1"
  }
}