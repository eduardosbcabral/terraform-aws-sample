 terraform {
  backend "s3" {
    bucket = "terraform-workplaces"
    key    = "us/rds/terraform.tfstate"
    region = "us-east-1"
  }
}