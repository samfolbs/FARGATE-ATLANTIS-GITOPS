module "atlantis" {
  source  = "terraform-aws-modules/atlantis/aws"

  name = "atlantis"

  # ECS Container Definition
  atlantis = {
    environment = [
      {
        name  = "ATLANTIS_GH_USER"
        value = "myuser"
      },
      {
        name  = "ATLANTIS_REPO_ALLOWLIST"
        value = "github.com/terraform-aws-modules/*"
      },
    ]
    secrets = [
      {
        name      = "ATLANTIS_GH_TOKEN"
        valueFrom = "arn:aws:secretsmanager:eu-west-1:111122223333:secret:aes256-7g8H9i"
      },
      {
        name      = "ATLANTIS_GH_WEBHOOK_SECRET"
        valueFrom = "arn:aws:secretsmanager:eu-west-1:111122223333:secret:aes192-4D5e6F"
      },
    ]
  }

  # ECS Service
  service = {
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:eu-west-1:111122223333:secret:aes256-7g8H9i",
      "arn:aws:secretsmanager:eu-west-1:111122223333:secret:aes192-4D5e6F",
    ]
    # Provide Atlantis permission necessary to create/destroy resources
    tasks_iam_role_policies = {
      AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
    }
  }
  service_subnets = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]
  vpc_id          = "vpc-1234556abcdef"

  # ALB
  alb_subnets             = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  certificate_domain_name = "example.com"
  route53_zone_id         = "Z2ES7B9AZ6SHAE"

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}