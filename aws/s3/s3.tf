resource "aws_s3_bucket" "terraform-s3-state" {
  bucket = "ds1-terraform-state"
  acl    = "private"
  region = "eu-west-1"

  versioning {
    enabled = true
  }
}
