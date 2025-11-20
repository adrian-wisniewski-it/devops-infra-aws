resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = "devops-aws-infra-tfstate-${random_id.suffix.hex}"

  tags = {
    Name = "devops-aws-infra-tfstate-bucket"
  }
}

resource "aws_s3_bucket_versioning" "tf_state_bucket_versioning" {
  bucket = aws_s3_bucket.tf_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}