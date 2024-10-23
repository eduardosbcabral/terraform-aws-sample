 terraform {
  backend "s3" {
    bucket = "terraform-states-edsbc"
    key    = "us/rds/terraform.tfstate"
    region = "us-east-1"
  }
}