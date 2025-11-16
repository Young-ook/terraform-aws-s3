[[English](README.md)] [[한국어](README.ko.md)]

# Amazon EMR (Elastic MapReduce)
[Amazon EMR](https://aws.amazon.com/emr/) is the industry-leading cloud big data solution for petabyte-scale data processing, interactive analytics, and machine learning using open-source frameworks such as Apache Spark, Apache Hive, and Presto.

![aws-emr-explorer](images/aws-emr-explorer.png)

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

## Data Catalog
- [What are the main features of Data Catalog software](https://www.techtarget.com/searchdatamanagement/answer/What-are-the-main-features-of-data-catalog-software)

## Data Lake
- [Data Lake](https://en.wikipedia.org/wiki/Data_lake)
- [What is a data lake?](https://aws.amazon.com/big-data/datalakes-and-analytics/what-is-a-data-lake/)
- [Introduction to Data Lakes](https://www.databricks.com/discover/data-lakes)

## Data Mesh
- [Data Mesh: A Monolithic Data Lake to a Distributed Data Mesh](https://martinfowler.com/articles/data-monolith-to-mesh.html)
- [Data Mesh Architecture](https://www.datamesh-architecture.com/)
- [Amazon DataZone - Data Mesh and Modern Data Architecture on AWS](https://youtu.be/arA-s8GTs6c?si=BsYUgAWNLrbsGbi8)
