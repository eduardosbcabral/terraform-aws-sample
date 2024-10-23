terraform {
  backend "s3" {
    bucket = "terraform-states-edsbc"
    key    = "us/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}