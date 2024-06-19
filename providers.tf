module "atlantis" {
  source  = "terraform-aws-modules/atlantis/aws"
  version = "4.3.0"
}


module "atlantis" {
  source  = "terraform-aws-modules/atlantis/aws"

  # ...

  atlantis = {
    environment = [
      {
        name : "ATLANTIS_REPO_CONFIG_JSON",
        value : jsonencode(yamldecode(file("${path.module}/server-atlantis.yaml"))),
      },
    ]
  }
}