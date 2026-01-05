terraform {
  backend "s3" {
    bucket = "mehdi_bucket_13651370"
    key    = "fortigate/dev/terraform.tfstate"
    region = "eu-central-1"
  }
}

