#there is no VPC creation bcoz S3 doesn't deploy inside a vpc 


#create s3 bucket

resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname
}


#change bucket OWNERSHIP to the bucket owner
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#allow PUBLIC access to the bucket
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# add bucket acl and make it PUBLIC-READ, more granular settings, won't work if block_public_acla is set to true
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"
}

#add index.html, error.html, profile.png objects to the bucket
resource "aws_s3_object" "index" {
  bucket = "${aws_s3_bucket.mybucket.id}"
  key    = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = "${aws_s3_bucket.mybucket.id}"
  key    = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "profile" {
  bucket = "${aws_s3_bucket.mybucket.id}"
  key    = "profile.png"
  source = "profile.png"
  acl = "public-read"
  //content_type = "i"
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

    depends_on = [ aws_s3_bucket_acl.example ]
}