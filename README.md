[[English](README.md)] [[한국어](README.ko.md)]

# Amazon S3 (Simple Storage Service)
[Amazon S3 (Simple Storage Service)](https://aws.amazon.com/s3/) is an object storage service that offers industry-leading scalability, data availability, security, and performance. Data Lake is one of pupular use cases of S3, which is a centralized repository that allows you to store all your structured and unstructured data at any scale. You can run data analytics, artificial intelligence (AI), machine learning (ML), and high-performance computing (HPC) applications to unlock the value of your data.

## Examples
- [Analytics on AWS](https://github.com/Young-ook/terraform-aws-s3/tree/main/examples/blueprint)
- [Data on Amazon EKS](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/data-ai)

## Getting started
### AWS CLI
Follow the official guide to install and configure profiles.
- [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

After the installation is complete, you can check the aws cli version:
```
aws --version
aws-cli/2.5.8 Python/3.9.11 Darwin/21.4.0 exe/x86_64 prompt/off
```

### Terraform
Terraform is an open-source infrastructure as code software tool that enables you to safely and predictably create, change, and improve infrastructure.

#### Install
This is the official guide for terraform binary installation. Please visit this [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) website and follow the instructions.

Or, you can manually get a specific version of terraform binary from the websiate. Move to the [Downloads](https://www.terraform.io/downloads.html) page and look for the appropriate package for your system. Download the selected zip archive package. Unzip and install terraform by navigating to a directory included in your system's `PATH`.

Or, you can use [tfenv](https://github.com/tfutils/tfenv) utility. It is very useful and easy solution to install and switch the multiple versions of terraform-cli.

First, install tfenv using brew.
```
brew install tfenv
```
Then, you can use tfenv in your workspace like below.
```
tfenv install <version>
tfenv use <version>
```
Also this tool is helpful to upgrade terraform v0.12. It is a major release focused on configuration language improvements and thus includes some changes that you'll need to consider when upgrading. But the version 0.11 and 0.12 are very different. So if some codes are written in older version and others are in 0.12 it would be great for us to have nice tool to support quick switching of version.
```
tfenv list
tfenv install latest
tfenv use <version>
```

### Setup
```hcl
module "s3" {
  source  = "Young-ook/s3/aws"
  name    = "datalake"
  tags    = { env = "test" }
}
```
Run terraform:
```
terraform init
terraform apply
```

## Object Lifecycle Management
To manage your objects so that they are stored cost effectively throughout their lifecycle, configure their Amazon S3 Lifecycle. An S3 Lifecycle configuration is a set of rules that define actions that Amazon S3 applies to a group of objects. There are two types of actions:
*  **Transition actions** Define when objects transition to another storage class. For example, you might choose to transition objects to the S3 Standard-IA storage class 30 days after you created them, or archive objects to the S3 Glacier storage class one year after creating them. There are costs associated with the lifecycle transition requests. For pricing information, see Amazon S3 pricing
* **Expiration actions** Define when objects expire. Amazon S3 deletes expired objects on your behalf. The lifecycle expiration costs depend on when you choose to expire objects.

For more information, see [Object lifecycle management](https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lifecycle-mgmt.html).

### Example
```
module "s3" {
  source  = "Young-ook/s3/aws"
  name    = "datalake"
  tags    = { env = "test" }

  lifecycle_rules = [{
    enabled = "true"
    transition = [{
      days          = "120"
      storage_class = "STANDARD_IA"
    }]
    expiration = {
      days = "160"
    }
  }]
}
```
Modify the terraform configuration file to add a lifecycle rule to apply objects in the S3 bucket.
```
terraform init
terraform apply
```

## Intelligent-Tiering
S3 Intelligent-Tiering is a new Amazon S3 storage class designed for customers who want to **optimize storage costs automatically when data access patterns change, without performance impact or operational overhead**. S3 Intelligent-Tiering is the first cloud object storage class that delivers automatic cost savings by moving data between access tiers — frequent access, infrequent access, archive, deep archive — when access patterns change, and is ideal for data with unknown or changing access patterns.

S3 Intelligent-Tiering stores objects in many access tiers. For a small monthly monitoring and automation fee per object, S3 Intelligent-Tiering monitors access patterns and moves objects that have not been accessed for 30 consecutive days to the infrequent access tier. There are no retrieval fees in S3 Intelligent-Tiering. If an object in the infrequent access tier is accessed later, it is automatically moved back to the frequent access tier. No additional tiering fees apply when objects are moved between access tiers within the S3 Intelligent-Tiering storage class. **S3 Intelligent-Tiering is designed for 99.9% availability and 99.999999999% durability, and offers the same low latency and high throughput performance of S3 Standard**.

For more information, see [Amazon S3 Intelligent-Tiering](https://docs.aws.amazon.com/AmazonS3/latest/userguide/intelligent-tiering.html).
Also, you can find out more about how to add archive tier to your Intelligent-Tiering stoage classes for lower stoage costs in this blog, [S3 Intelligent-Tiering Adds Archive Access Tiers](https://aws.amazon.com/blogs/aws/s3-intelligent-tiering-adds-archive-access-tiers/).

### Example
```hcl
module "s3" {
  source  = "Young-ook/s3/aws"
  name    = "datalake"
  tags    = { env = "test" }

  lifecycle_rules = [{
    enabled = "true"
    transition = [
      {
        "days" : "0",
        "storage_class" : "INTELLIGENT_TIERING"
      },
    ]
  }]
  intelligent_tiering_archive_rules = {
    state = "Enabled"
    filter = [{
      prefix = "logs/"
      tags = {
        priority = "high"
        class    = "blue"
      }
    }]
    tiering = [{
      access_tier = "ARCHIVE_ACCESS"
      days        = 125
    }, {
      access_tier = "DEEP_ARCHIVE_ACCESS"
      days        = 180
    }]
  }
}
```
Modify the terraform configuration file to add a lifecycle rule to apply objects in the S3 bucket.
```
terraform init
terraform apply
```

## Bucket Policy
With Amazon S3 bucket policies, you can secure access to objects in your buckets, so that only users with the appropriate permissions can access them. You can even prevent authenticated users without the appropriate permissions from accessing your Amazon S3 resources. This example shows how to configure a bucket policy to allow access to buckets through VPC endpoints only for security and compliance.

For more information, refer to the [Controlling access from VPC endpoints with bucket policies](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies-vpc-endpoint.html) user guide.

### Example
```hcl
module "s3" {
  source  = "Young-ook/s3/aws"
  name    = "datalake"
  tags    = { env = "test" }

  bucket_policy = {
    vpce-only = {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid = "AllowAccessFromVpcEndpoint"
            Action = [
              "s3:GetObject",
              "s3:PutObject",
              "s3:ListBucket"
            ]
            Effect = "Deny"
            Principal = {
              AWS = flatten([module.aws.caller.account_id, ])
            }
            Resource = [join("/", [module.s3.bucket.arn, "*"]), module.s3.bucket.arn, ]
            Condition = {
              StringNotEquals = {
                "aws:sourceVpce" = module.vpc.vpce.s3.id
              }
            }
          },
        ]
      })
    }
  }
}
```
Modify the terraform configuration file to apply a bucket policy for access control.
```
terraform init
terraform apply
```

# Additional Resources
## Mountpoint for Amazon S3
- [Working with Mountpoint for Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/mountpoint.html)
- [Mountpoint for Amazon S3 configuration](https://github.com/awslabs/mountpoint-s3/blob/main/doc/CONFIGURATION.md)
- [Mountpoint for Amazon S3 file system behavior](https://github.com/awslabs/mountpoint-s3/blob/main/doc/SEMANTICS.md)

## Storage Cost Optimization
* [How to optimize storage costs using Amazon S3](https://d1.awsstatic.com/product-marketing/S3/Amazon_S3_eBook_Cost_Optimization.pdf)
* [5 Ways to reduce data storage costs using Amazon S3 Storage Lens](https://aws.amazon.com/blogs/storage/5-ways-to-reduce-costs-using-amazon-s3-storage-lens/)
* [Amazon S3 cost optimization for predictable and dynamic access patterns](https://aws.amazon.com/blogs/storage/amazon-s3-cost-optimization-for-predictable-and-dynamic-access-patterns/)
* [Expiring Amazon S3 Objects Based on Last Accessed Date to Decrease Costs](https://aws.amazon.com/blogs/architecture/expiring-amazon-s3-objects-based-on-last-accessed-date-to-decrease-costs/)

## Storage Class
- [Amazon S3 Glacier is the Best Place to Archive Your Data – Introducing the S3 Glacier Instant Retrieval Storage Class](https://aws.amazon.com/blogs/aws/amazon-s3-glacier-is-the-best-place-to-archive-your-data-introducing-the-s3-glacier-instant-retrieval-storage-class/)
- [Announcing the new Amazon S3 Express One Zone high performance storage class](https://aws.amazon.com/blogs/aws/new-amazon-s3-express-one-zone-high-performance-storage-class/)

## Governance
- [Monitor, review, and protect Amazon S3 buckets using Access Analyzer for S3](https://aws.amazon.com/blogs/storage/protect-amazon-s3-buckets-using-access-analyzer-for-s3/)
