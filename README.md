# Hi! 
This Terraform script creates an AWS EKS cluster with additional applications installed. Best practices and IRSA have been used, and application versions are mostly pinned.

The cluster is deployed into an existing VPC. 

Before creating it, you need to set up a VPC, an S3 bucket for storing the state file, tfvars, and SSH keys for instance access.

For the subnets where the cluster will run, you need to set the tag kubernetes.io/role/elb=1.

A PostgreSQL database must also be created for Grafana and be accessible from the current VPC. Grafana requires an email account, so make sure to create one as well.

I have decided not to use Let's Encrypt and prefer a certificate from AWS or to import my own into the AWS certificate store.

# Prepare env for deploy:

- create VPC

- create DB for Grafana

- Import or Request SSL certificate https://us-east-1.console.aws.amazon.com/acm/home?region=us-east-1#/certificates/list

- Create S3 bucket for store Terraform state files like "terraform-state-env"

- Set email user and pw (smtp gmail used)


# Deploy Kubernetes and app with Terraform
## Dev env
1. Download file TFVARS from S3 (or create one)
aws s3 cp s3://terraform-state-env/k8s-dev/terraform.tfvars .
2. Edit files
 - /terraform-eks-deploy/environments/dev/main.tf
 - /terraform-eks-deploy/environments/dev/terraform.tfvars
3. Init terraform
```
terraform init \
  -backend-config="bucket=terraform-state-env" \
  -backend-config="key=k8s-dev/terraform.tfstate"
```


  **This script will install next components:**

- Create SSH key pair for Workers Nodes and put it to the S3 bucket
  
- VPC (just set vars, used module fake_vpc)

- install EKS with AWS apps

- add Metrix Service to the cluster

- set Storage Class EFS (I know this is more expensive than EBS but zone independent)

- ingress (ELB + ingress-nginx) with SSL termination

- loki (use personal S3 bucket and EFS disk)

- External Secrets (and put there email auth data)

- prometheus + grafana (use EFS disk, )

- ArgoCD

- Create IRSA for API


# Notes

The modules folder also contains unused modules, but I kept them for future configurations. It includes modules for creating a jump host, a VPC, and certificate generation (if the zone is in Route 53).