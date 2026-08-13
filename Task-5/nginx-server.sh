#!/bin/bash

set -e

echo "========================================"
echo " Nginx Web Server Installation"
echo "========================================"

# Must run as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root."
    exit 1
fi

# Detect operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "ERROR: Cannot detect operating system."
    exit 1
fi

echo "Detected OS: $PRETTY_NAME"

# ========================================
# Install Nginx
# ========================================

case "$ID" in

    ubuntu|debian)

        echo "Ubuntu/Debian detected."

        echo "Updating package repositories..."
        apt-get update -y

        echo "Installing Nginx..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

        WEB_ROOT="/var/www/html"

        ;;

    rhel|redhat|centos|rocky|almalinux|fedora)

        echo "RHEL-based operating system detected."

        echo "Installing Nginx..."
        dnf install -y nginx

        WEB_ROOT="/usr/share/nginx/html"

        ;;

    *)

        echo "ERROR: Unsupported operating system: $ID"
        exit 1

        ;;

esac

# ========================================
# Create Web Page
# ========================================

echo "Creating webpage..."

mkdir -p "$WEB_ROOT"

cat > "$WEB_ROOT/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Azure Nginx Server</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f6f8;
            margin: 0;
            height: 100vh;

            display: flex;
            justify-content: center;
            align-items: center;
        }

        .container {
            background: white;
            padding: 50px;
            border-radius: 12px;

            text-align: center;

            box-shadow:
                0 4px 20px rgba(0, 0, 0, 0.1);
        }

        h1 {
            color: #0078d4;
        }

        p {
            color: #555;
            font-size: 18px;
        }

        .status {
            color: green;
            font-weight: bold;
        }
    </style>
</head>

<body>

    <div class="container">

        <h1>Hello from Azure!</h1>

        <p>
            Nginx is successfully running.
        </p>

        <p>
            Operating System:
            <strong>Linux</strong>
        </p>

        <p class="status">
            Nginx Status: Running
        </p>

        <p>
            This webpage was deployed using
            Azure Custom Script Extension.
        </p>

    </div>

</body>

</html>
EOF

# ========================================
# Set Permissions
# ========================================

echo "Setting webpage permissions..."

chmod 755 "$WEB_ROOT"
chmod 644 "$WEB_ROOT/index.html"

# ========================================
# Enable and Start Nginx
# ========================================

echo "Enabling Nginx at boot..."

systemctl enable nginx

echo "Starting Nginx..."

systemctl restart nginx

# ========================================
# Configure Firewall
# ========================================

echo "Checking local firewall..."

if command -v firewall-cmd >/dev/null 2>&1; then

    if systemctl is-active --quiet firewalld; then

        echo "firewalld detected and running."

        firewall-cmd --permanent --add-service=http
        firewall-cmd --reload

        echo "HTTP allowed through firewalld."

    else

        echo "firewalld is installed but not running."
        echo "Skipping firewalld configuration."

    fi

elif command -v ufw >/dev/null 2>&1; then

    if ufw status | grep -q "Status: active"; then

        echo "UFW detected and running."

        ufw allow 80/tcp

        echo "HTTP allowed through UFW."

    else

        echo "UFW is installed but not active."
        echo "Skipping UFW configuration."

    fi

else

    echo "No supported local firewall detected."

fi

# ========================================
# Test Nginx Configuration
# ========================================

echo "Testing Nginx configuration..."

nginx -t

# ========================================
# Verify Nginx Service
# ========================================

echo "Checking Nginx service..."

if systemctl is-active --quiet nginx; then

    echo "========================================"
    echo " Nginx is RUNNING"
    echo "========================================"

else

    echo "========================================"
    echo " ERROR: Nginx failed to start"
    echo "========================================"

    systemctl status nginx --no-pager

    exit 1

fi

# ========================================
# Test HTTP Locally
# ========================================

echo "Testing HTTP locally..."

if command -v curl >/dev/null 2>&1; then

    HTTP_STATUS=$(curl -o /dev/null \
        -s \
        -w "%{http_code}" \
        http://localhost)

    echo "HTTP status: $HTTP_STATUS"

    if [ "$HTTP_STATUS" = "200" ]; then
        echo "Local HTTP test successful."
    else
        echo "WARNING: HTTP returned status $HTTP_STATUS"
    fi

else

    echo "curl is not installed."
    echo "Skipping HTTP test."

fi

# ========================================
# Display Information
# ========================================

echo ""
echo "========================================"
echo " Installation Complete"
echo "========================================"
echo ""
echo "Operating System : $PRETTY_NAME"
echo "Web Server       : Nginx"
echo "Web Root         : $WEB_ROOT"
echo "HTTP Port        : 80"
echo "Service Status   : $(systemctl is-active nginx)"
echo ""
echo "Test locally:"
echo "    curl http://localhost"
echo ""
echo "========================================"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         