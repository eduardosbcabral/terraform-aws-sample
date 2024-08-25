 terraform {
  backend "s3" {
    bucket = "terraform-workplaces"
    key    = "us/dns/terraform.tfstate"
    region = "us-east-1"
  }
}