 terraform {
  backend "s3" {
    bucket = "terraform-workplaces"
    key    = "us/microservices/terraform.tfstate"
    region = "us-east-1"
  }
}