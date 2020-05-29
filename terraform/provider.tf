provider "aws" {
  region  = "ap-southeast-2"
  version = ">= 2.00"
  profile = "${var.env}-datawarehouse"
}

provider "aws" {
  region  = "us-east-1"
  alias   = "us-east-1"
  version = ">= 2.00"
  profile = "${var.env}-datawarehouse"
}
