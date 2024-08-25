terraform {
  backend "s3" {
    bucket = "terraform-workplaces"
    key    = "us/alb/terraform.tfstate"
    region = "us-east-1"
  }
}