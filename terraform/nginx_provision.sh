#!/bin/bash

# Provisioning script for the proxy instance
# This script installs and configures NGINX to act as a reverse proxy for a Kubernetes API endpoint.

# Log the start of the provisioning process
echo "Starting provisioning..." | tee -a /var/log/provisioning.log

# Debug: Log the current date and time
echo "Current date and time: $(date)" | tee -a /var/log/provisioning.log

# Wait for the dpkg lock to be released (with a timeout)
timeout=300 # Timeout in seconds (5 minutes)
elapsed=0
echo "Checking for dpkg lock..." | tee -a /var/log/provisioning.log
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "Waiting for dpkg lock to be released..." | tee -a /var/log/provisioning.log

    # Detect the process holding the lock
    lock_holder=$(sudo lsof /var/lib/dpkg/lock-frontend | awk 'NR==2 {print $2}')
    if [ -n "$lock_holder" ]; then
        echo "Process $lock_holder is holding the dpkg lock. Attempting to terminate it..." | tee -a /var/log/provisioning.log
        sudo kill "$lock_holder"

        # Wait for the process to terminate
        sleep 5
        if ps -p "$lock_holder" > /dev/null 2>&1; then
            echo "Process $lock_holder did not terminate. Forcibly killing it..." | tee -a /var/log/provisioning.log
            sudo kill -9 "$lock_holder"
        fi
    fi

    # Increment elapsed time and check for timeout
    sleep 5
    elapsed=$((elapsed + 5))
    if [ $elapsed -ge $timeout ]; then
        echo "Timeout waiting for dpkg lock. Exiting." | tee -a /var/log/provisioning.log
        exit 1
    fi
done
echo "dpkg lock released. Proceeding with package updates..." | tee -a /var/log/provisioning.log

# Update system packages
echo "Updating system packages..." | tee -a /var/log/provisioning.log
if ! sudo DEBIAN_FRONTEND=noninteractive apt-get update -y; then
    echo "Failed to run 'apt-get update'. Exiting." | tee -a /var/log/provisioning.log
    exit 1
fi
echo "'apt-get update' completed successfully." | tee -a /var/log/provisioning.log

# Upgrade system packages
echo "Upgrading system packages..." | tee -a /var/log/provisioning.log
if ! sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y 2>&1 | tee -a /var/log/provisioning.log; then
    echo "Failed to run 'apt-get upgrade'. Exiting." | tee -a /var/log/provisioning.log
    exit 1
fi
echo "'apt-get upgrade' completed successfully." | tee -a /var/log/provisioning.log

# Install NGINX
echo "Installing NGINX..." | tee -a /var/log/provisioning.log
if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx; then
    echo "Failed to install NGINX. Exiting." | tee -a /var/log/provisioning.log
    exit 1
fi
echo "NGINX installed successfully." | tee -a /var/log/provisioning.log

# Configure NGINX to forward traffic to the Kubernetes API
echo "Configuring NGINX..." | tee -a /var/log/provisioning.log

# Strip "https://" from the Kubernetes API endpoint if present
KUBERNETES_API_ENDPOINT=$(echo "$1" | sed 's~https://~~g')
if [ -z "$KUBERNETES_API_ENDPOINT" ]; then
    echo "No Kubernetes API endpoint provided. Exiting." | tee -a /var/log/provisioning.log
    exit 1
fi
echo "Using Kubernetes API endpoint: ${KUBERNETES_API_ENDPOINT}" | tee -a /var/log/provisioning.log

# Create the NGINX configuration file
cat <<EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 6443;
    location / {
        proxy_pass http://${KUBERNETES_API_ENDPOINT}; # Forward traffic to the Kubernetes API
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
echo "NGINX configuration file created successfully." | tee -a /var/log/provisioning.log

# Test NGINX configuration
echo "Testing NGINX configuration..." | tee -a /var/log/provisioning.log
if ! sudo nginx -t 2>&1 | tee -a /var/log/provisioning.log; then
    echo "NGINX configuration test failed. Exiting." | tee -a /var/log/provisioning.log
    exit 1
fi
echo "NGINX configuration test passed." | tee -a /var/log/provisioning.log

# Restart NGINX
echo "Restarting NGINX..." | tee -a /var/log/provisioning.log
if ! sudo systemctl restart nginx; then
    echo "Failed to restart NGINX. Exiting." | tee -a /var/log/provisioning.log
    exit 1
fi
echo "NGINX restarted successfully." | tee -a /var/log/provisioning.log

# Allow traffic on port 6443 (optional, for UFW)
if sudo ufw status | grep -q "Status: active"; then
    echo "Allowing traffic on port 6443..." | tee -a /var/log/provisioning.log
    sudo ufw allow 6443
    sudo ufw reload
    echo "Firewall updated to allow traffic on port 6443." | tee -a /var/log/provisioning.log
fi

# Final confirmation
echo "Provisioning complete!" | tee -a /var/log/provisioning.log
echo "Using Kubernetes API endpoint: ${KUBERNETES_API_ENDPOINT}" | tee -a /var/log/provisioning.log
echo "Provisioning finished at: $(date)" | tee -a /var/log/provisioning.log