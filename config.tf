resource "null_resource" "configure_atlantis" {
  provisioner "local-exec" {
    command = <<EOF
cat <<EOT > atlantis.yaml
github:
  user: "${var.github_username}"
  token: "${var.github_token}"
  webhook_secret: "${var.github_webhook_secret}"

server:
  port: ${var.atlantis_port}
  repo_config: "${var.atlantis_repo_config}"
  delete_source_branch_on_merge: ${var.atlantis_delete_source_branch_on_merge}
  log_level: "${var.atlantis_log_level}"
  auto_apply: ${var.atlantis_auto_apply}
  parallel_plan: ${var.atlantis_parallel_plan}
EOT
EOF
  }
}