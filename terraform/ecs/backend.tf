terraform {
  backend "s3" {
    bucket = "terraform-workplaces"
    key    = "us/ecs/terraform.tfstate"
    region = "us-east-1"
  }
}