```hcl
module "atlantis" {
  source  = "terraform-aws-modules/atlantis/aws"

  # Truncated for brevity ...

  # EFS
  enable_efs = true
  efs = {
    mount_targets = {
      "eu-west-1a" = {
        subnet_id = "subnet-xyzde987"
      }
      "eu-west-1b" = {
        subnet_id = "subnet-slkjf456"
      }
      "eu-west-1c" = {
        subnet_id = "subnet-qeiru789"
      }
    }
  }
}