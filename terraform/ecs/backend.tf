terraform {
  backend "s3" {
    bucket = "terraform-states-edsbc"
    key    = "us/ecs/terraform.tfstate"
    region = "us-east-1"
  }
}