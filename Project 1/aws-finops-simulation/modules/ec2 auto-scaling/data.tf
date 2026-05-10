# WHY:
# cloudinit_config combines multiple startup scripts into a single user data configuration.
# This allows EC2 instances launched by the ASG to automatically configure themselves during boot.

data "cloudinit_config" "combined_scripts" {
  gzip          = false
  base64_encode = true

  # Script 1 : Web Server Setup
  # WHY:
  # This script automatically installs and configures the web application during instance startup.
  # Using templatefile allows dynamic values like website directory and GitHub repository to be injected.

  part {
    content_type = "text/x-shellscript"

    content = templatefile("${path.module}/scripts/web-server-setup.sh", {
      website_directory = var.website_directory
      github_repository = var.github_repository
    })
  }

  # Script 2 : Stress Test Setup (stress-ng)
  # WHY:
  # This script installs stress testing tools used to simulate predictable traffic and sudden workload spikes.
  # It helps validate Auto Scaling behavior and infrastructure monitoring workflows.

  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/scripts/web-server-stress-test-setup.sh")
  }
}