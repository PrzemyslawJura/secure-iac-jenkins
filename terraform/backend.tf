terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "secure-iac-demo/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
