resource "aws_iam_policy" "s3_restrict_policy" {
  name        = "app-s3-specific-bucket-access"
  description = "Allow EC2 to access only the specific S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListAllMyBuckets"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = [
          "${aws_s3_bucket.data_bucket.arn}",
          "${aws_s3_bucket.data_bucket.arn}/*",
          "${aws_s3_bucket.records_bucket.arn}",
          "${aws_s3_bucket.records_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "restricted_app_s3_access" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.s3_restrict_policy.arn
}


resource "aws_s3_bucket" "data_bucket" {
  bucket        = format("%s-data", random_string.random_name.result)
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "data_bucket_public_access_block" {
  bucket = aws_s3_bucket.data_bucket.id
  block_public_acls       = true        
  block_public_policy     = true        
  ignore_public_acls      = true        
  restrict_public_buckets = true        
}


resource "aws_s3_object" "cardfiles" {
  bucket     = aws_s3_bucket.data_bucket.id
  key        = "creditcards.txt"
  source     = "creditcards.txt"
  depends_on = [aws_s3_bucket.data_bucket]
}


resource "aws_s3_bucket_acl" "data_bucket_acl" {
  bucket     = aws_s3_bucket.data_bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket.data_bucket,aws_s3_bucket_ownership_controls.data_bucket_ownership_controls]
}

resource "aws_s3_bucket_ownership_controls" "data_bucket_ownership_controls" {
  bucket = aws_s3_bucket.data_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}



resource "aws_s3_bucket" "records_bucket" {
  bucket        = format("%s-records", random_string.random_name.result)
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "records_bucket_public_access_block" {
  bucket = aws_s3_bucket.records_bucket.id
  block_public_acls       = true        
  block_public_policy     = true        
  ignore_public_acls      = true        
  restrict_public_buckets = true        
}

resource "aws_s3_object" "records_files" {
  bucket     = aws_s3_bucket.records_bucket.id
  key        = "records.txt"
  source     = "medical_records.txt"
  depends_on = [aws_s3_bucket.records_bucket]
}

resource "aws_s3_bucket_acl" "records_bucket_acl" {
  bucket     = aws_s3_bucket.records_bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket.records_bucket , aws_s3_bucket_ownership_controls.records_bucket_ownership_controls]
}

resource "aws_s3_bucket_ownership_controls" "records_bucket_ownership_controls" {
  bucket = aws_s3_bucket.records_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}