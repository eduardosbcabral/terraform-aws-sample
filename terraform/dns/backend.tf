 terraform {
  backend "s3" {
    bucket = "terraform-states-edsbc"
    key    = "us/dns/terraform.tfstate"
    region = "us-east-1"
  }
}