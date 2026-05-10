#!/bin/bash

# WHY:
# Enables strict error handling for safer and more reliable automation execution.
# The script exits immediately if any command fails.

set -euxo pipefail

# WHY:
# Logs deployment progress during EC2 instance initialization.
# Helpful for debugging user data execution using cloud-init logs.

echo "Starting html,css and javascript website deployment...."

# WHY:
# Updates installed system packages to ensure security patches and latest dependencies are available.
# Reduces compatibility and package-related issues during setup.

sudo yum update -y
sudo yum upgrade -y

# WHY:
# Installs Git for repository management and Apache (httpd) for serving the website.
# These are required for web application deployment and hosting.

sudo yum install -y git httpd

# WHY:
# Moves into the website deployment directory where application files will be stored.
# Keeps website content organized inside the web server root path.

cd ${website_directory}

# WHY:
# Creates a basic HTML page automatically during instance startup.
# This validates successful web server deployment and application accessibility.

sudo tee index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>HubSpot Project</title>
</head>
<body>
    <h1>Welcome to My Website</h1>
    <p>File created via terminal using sudo, tee, and EOF.</p>
</body>
</html>
EOF

# WHY:
# Assigns proper ownership and permissions to website files for Apache access.
# Ensures the web server can securely read and serve application content.

sudo chown -R apache:apache ${website_directory}
sudo chmod -R 755 ${website_directory}

# WHY:
# Enables Apache to start automatically during instance boot and starts the service immediately.
# This ensures the website becomes accessible as soon as the instance launches.

sudo systemctl enable httpd
sudo systemctl start httpd