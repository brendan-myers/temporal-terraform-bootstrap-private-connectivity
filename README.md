# Temporal / AWS Private Connectivity Bootstrap

Bootstraps a Temporal Cloud namespace, an AWS VPC with private connectivity to the namespace, and an EC2 host (with no public connectivity, but with private connectivity to Temporal) to test the connection.

## Setup
* Set the `TEMPORAL_CLOUD_API_KEY` environment variable (or [set them in the provider directly](https://registry.terraform.io/providers/temporalio/temporalcloud/latest/docs#provider-configuration) - not recommended!)
* Set your AWS credentials for the Terraform AWS Provider. [Instructions here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration).
* (optional) This creates an EC2 instance that doesn't have access to the public internet, but it does have access to S3. If you want to test connectivity from the EC2 instance to Temporal Cloud, then set the [`tf-temporal-cli-us-east-1`](config/common.auto.tfvars) variable to an S3 bucket containing the Temporal CLI. **Note:** this bucket must be in the same region as the AWS VPC, and the CLI binary must be built for the same architecture as the AMI specified with the [`ami`](config/common.auto.tfvars) variable. **Special second note:** If you are internal to Temporal, use the defaults (`us-east-1`) as this is already set up.


## Running
```
make init
make apply
```
Terraform will prompt you for a name for the Temporal Namespace and for confirmation to create everything.

Find your EC2 instance in the AWS console, and connect to it with SSM (select your instance, Connect, Session Manager, Connect).

```
sudo su - ec2-user
./test.sh
```

This script will start a workflow, sleep for 5 seconds, and list running workflows. If you see no errors then everything is working correctly.

## Clean up
```
make destroy
```