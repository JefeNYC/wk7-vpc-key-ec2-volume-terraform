resource "aws_s3_bucket" "example" {
  bucket = "week7-dss-bucket-jefe"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}