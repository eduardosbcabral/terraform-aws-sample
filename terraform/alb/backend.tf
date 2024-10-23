terraform {
  backend "s3" {
    bucket = "terraform-states-edsbc"
    key    = "us/alb/terraform.tfstate"
    region = "us-east-1"
  }
}