terraform {
  backend "s3" {
    bucket = "terraform-workplaces"
    key    = "us/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}