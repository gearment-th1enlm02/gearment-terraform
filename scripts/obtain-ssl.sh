#!/bin/bash

# Obtain SSL certificate with retry
echo "Obtaining SSL certificate..."
for i in {1..3}; do
    if sudo certbot --nginx -d "gearment.th1enlm02devops.engineer" -d "gearment-api.th1enlm02devops.engineer" --non-interactive --agree-tos -m minhthienluu2406@gmail.com; then
        break
    fi
    echo "Certbot failed, retrying ($i/3)..."
    sleep 10
done
sudo systemctl reload nginx