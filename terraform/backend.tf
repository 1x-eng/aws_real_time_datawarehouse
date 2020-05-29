terraform {
  backend "s3" {
    # This block can't be parameterized. Wth terraform!
    key            = "state/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "TerraformStateLock"
  }
}
