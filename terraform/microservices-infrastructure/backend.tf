 terraform {
  backend "s3" {
    bucket = "terraform-states-edsbc"
    key    = "us/microservices/terraform.tfstate"
    region = "us-east-1"
  }
}