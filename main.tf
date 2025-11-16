### simple storage service

locals {
  directory_bucket = var.zone_id != null ? true : false
  general_bucket   = !local.directory_bucket
}

### security/policy
resource "aws_iam_policy" "read" {
  name        = format("%s-read", local.name)
  description = format("Allow to download/read objects from the S3 bucket")
  path        = "/"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "s3:HeadBucket",
          "s3:List*",
          "s3:Get*",
        ]
        Effect   = "Allow"
        Resource = [local.bucket_arn, local.bucket_arn_with_slash]
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "write" {
  name        = format("%s-write", local.name)
  description = format("Allow to upload/write objects into the S3 bucket")
  path        = "/"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "s3:Put*",
          "s3:DeleteObject*",
          "s3:AbortMultipartUpload",
        ]
        Effect   = "Allow"
        Resource = [local.bucket_arn_with_slash]
      },
      {
        Action = [
          "s3:HeadBucket",
        ]
        Effect   = "Allow"
        Resource = [local.bucket_arn]
      }
    ]
    Version = "2012-10-17"
  })
}

### security/policy
resource "aws_s3_bucket_policy" "bucket" {
  for_each   = var.bucket_policy == null ? {} : var.bucket_policy
  depends_on = [aws_s3_bucket_public_access_block.bucket]
  bucket     = (local.directory_bucket ? aws_s3_directory_bucket.bucket["enabled"].id : aws_s3_bucket.bucket["enabled"].id)
  policy     = lookup(each.value, "policy", null)
}

### security/policy
resource "aws_s3_bucket_public_access_block" "bucket" {
  for_each                = (local.general_bucket ? toset(["enabled"]) : [])
  bucket                  = aws_s3_bucket.bucket["enabled"].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

### storage/bucket
resource "aws_s3_bucket" "bucket" {
  for_each      = (local.general_bucket ? toset(["enabled"]) : [])
  bucket        = local.name
  tags          = merge(local.default-tags, var.tags)
  force_destroy = var.force_destroy
}

resource "aws_s3_directory_bucket" "bucket" {
  for_each = (local.directory_bucket ? toset(["enabled"]) : [])
  bucket   = join("--", [local.name, var.zone_id, "x-s3"])
  location {
    name = var.zone_id
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = (var.versioning != null && local.general_bucket ? toset(["enabled"]) : [])
  bucket   = aws_s3_bucket.bucket["enabled"].id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  for_each = (var.server_side_encryption != null && local.general_bucket ? toset(["enabled"]) : [])
  bucket   = aws_s3_bucket.bucket["enabled"].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = lookup(var.server_side_encryption, "sse_algorithm", null)
      kms_master_key_id = lookup(var.server_side_encryption, "kms_master_key_id", null)
    }
  }
}

resource "aws_s3_bucket_logging" "log" {
  for_each      = (var.logging_rules != null && local.general_bucket ? toset(["enabled"]) : [])
  bucket        = aws_s3_bucket.bucket["enabled"].id
  target_bucket = lookup(var.logging_rules, "target_bucket", local.name)
  target_prefix = lookup(var.logging_rules, "target_prefix", "log/")
}

resource "aws_s3_bucket_lifecycle_configuration" "lc" {
  for_each = (var.lifecycle_rules != null && local.general_bucket ? toset(["enabled"]) : [])
  bucket   = aws_s3_bucket.bucket["enabled"].id

  dynamic "rule" {
    for_each = { for k, v in var.lifecycle_rules : k => v }
    content {
      id     = lookup(rule.value, "id")
      status = lookup(rule.value, "status", "Disabled")

      dynamic "filter" {
        for_each = { for k, v in rule.value : k => v if k == "filter" }
        content {
          prefix = lookup(filter.value, "prefix", null)
          dynamic "tag" {
            for_each = { for k, v in lookup(filter.value, "tag", []) : k => v }
            content {
              key   = lookup(tag.value, "key")
              value = lookup(tag.value, "value")
            }
          }
        }
      }

      dynamic "expiration" {
        for_each = { for k, v in rule.value : k => v if k == "expirarion" }
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])
        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = { for k, v in rule.value : k => v if k == "noncurrent_version_expiration" }
        content {
          noncurrent_days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transition", [])
        content {
          noncurrent_days = lookup(noncurrent_version_transition.value, "days", null)
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "int" {
  for_each = { for k, v in(var.intelligent_tiering_archive_rules != null && local.general_bucket ? var.intelligent_tiering_archive_rules : []) : k => v }
  bucket   = aws_s3_bucket.bucket["enabled"].id
  name     = local.name
  status   = lookup(each.value, "status", "Disabled")

  dynamic "filter" {
    for_each = { for k, v in lookup(each.value, "filter", []) : k => v }
    content {
      prefix = lookup(filter.value, "prefix")
      tags   = lookup(filter.value, "tags")
    }
  }

  dynamic "tiering" {
    for_each = { for k, v in lookup(each.value, "tiering", []) : k => v }
    content {
      access_tier = lookup(tiering.value, "access_tier")
      days        = lookup(tiering.value, "days")
    }
  }
}

### utility/script
resource "local_file" "empty" {
  for_each        = (var.force_destroy ? toset(["enabled"]) : [])
  content         = "bash ${path.module}/scripts/empty.sh -r ${local.aws.region} -b ${local.bucket_name}"
  filename        = join("/", [path.module, "force-destroy.sh"])
  file_permission = "0600"
}

resource "null_resource" "force_destroy" {
  depends_on = [local_file.empty]
  for_each   = (var.force_destroy ? toset(["enabled"]) : [])
  provisioner "local-exec" {
    when    = destroy
    command = "bash ${path.module}/force-destroy.sh"
  }
}
