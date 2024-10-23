terraform {
  backend "s3" {
    bucket = "terraform-states-edsbc"
    key    = "us/acm/terraform.tfstate"
    region = "us-east-1"
  }
}