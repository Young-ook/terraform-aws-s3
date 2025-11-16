### default values

### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  aws = {
    region = module.aws.region.name
  }
}

locals {
  default_lifecycle_rules                   = null
  default_intelligent_tiering_archive_rules = null
}
