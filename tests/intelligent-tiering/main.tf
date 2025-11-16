terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "main" {
  source        = "../.."
  versioning    = "Enabled"
  force_destroy = true
  lifecycle_rules = [
    {
      id     = "intelligent_tiering"
      status = "Enabled"
      filter = {
        prefix = ""
      }
      expiration = {
        days = 365
      }
      transition = [
        {
          days = 0
          # valid values for 'storage_class':
          #   STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING,
          #   GLACIER, DEEP_ARCHIVE, GLACIER_IR
          storage_class = "INTELLIGENT_TIERING"
        },
        {
          days          = 180
          storage_class = "GLACIER_IR"
        },
      ]
      noncurrent_version_expiration = {
        days = 120
      }
      noncurrent_version_transition = []
    },
    {
      id     = "infrequent_access"
      status = "Enabled"
      filter = {
        prefix = ""
      }
      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
      ]
    },
    {
      id     = "glacier"
      status = "Disabled"
      filter = {
        prefix = ""
      }
      transition = [
        {
          days          = 360
          storage_class = "GLACIER"
        },
      ]
    },
  ]
}
