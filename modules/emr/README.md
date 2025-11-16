[[English](README.md)] [[한국어](README.ko.md)]

# Amazon EMR (Elastic MapReduce)
[Amazon EMR](https://aws.amazon.com/emr/) is the industry-leading cloud big data solution for petabyte-scale data processing, interactive analytics, and machine learning using open-source frameworks such as Apache Spark, Apache Hive, and Presto.

**Explore Amazon EMR**
- Amazon EMR on [Amazon EC2](https://github.com/Young-ook/terraform-aws-ec2): Process and analysis data for Machine Learning, scientific simulation, data mining, web indexing, log file analysis and data warehousing based on virtual machine computring environment
- Amazon EMR Studio: Manage Jupyter notebooks that runs on Amazon EMR clusters and debig applications, such as Apache Spark
- Amazon EMR Serverless: Run big data applications using open-source frameworks without managing clusters and servers
- Amazon EMR on [EKS](https://github.com/Young-ook/terraform-aws-eks): Run open-source big data frameworks on Amazon Elastic Kubernetes Service

## Getting started
### Prerequisites
This module requires terraform. If you don't have the terraform tools in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-s3) of this repository and follow the installation instructions before you move to the next step.

### Setup
```hcl
module "emr" {
  source  = "Young-ook/s3/aws//modules/emr"
  name    = "emr"
}
```
Run terraform:
```
terraform init
terraform apply
```

# Additional Resources
## Amazon EMR (Elastic MapReduce)
- [Amazon EMR Migration TCO(Total Cost of Ownership) Simulator](https://github.com/awslabs/migration-hadoop-to-emr-tco-simulator)

