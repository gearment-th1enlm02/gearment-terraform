#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

PUBLIC_KEY_1="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJOHXl8zh5EW2sk+tv24aMxhPgbCkK4+XRIpXhJPaHBVBavT5KOTrTkZaeTLxWVSyY8jKikgB5ejWXRTX1UJbvH10jE+4Av0jyR/v8BzbWPeZdO+MxEcKJffllR0gmWgeqsFVqrJeDqdqFD73KaPGPQmAgKScA7MDAHdv67mz7d9wssVYUGox87qixzBjXoXHmlX1x18CMgGRkWI+PdVsngTpbhW2ZrQGKGKFCVDvvMeCGsynuYdwzPLsW0h+REzbg8yVnsES10sbQG/TWd7wv4KYKHHME5pbU5/2pJXauRK1GheX7hK/6rJoKHYC/QqXiIUL/C/P7jsA35/ujfvba9DXisq5OFG69n3eeKSWWEgFsqcC0NKJdY+rPmIUDiZSV8szr/8eXtbndiNpVN+hsHowdAXRWPTYisPXif4ShNaCYpZmKMfpdqsAW6Br+afjEkoeGUE1/kDdd3Ua4hYvDnXC/BNrOrNiGSvJoBZRROWNsMM0gBGK2mYxfwrFH8Zc= lenovo@MinhThien-Luu"
PUBLIC_KEY_2="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKW2m1T91W8YhtFbufHyBmMEkenzN6MpYJ5zYFsf06Ja wsl@minhthien-luu"
echo "Adding SSH keys..."
echo "$PUBLIC_KEY_1" >> /home/ubuntu/.ssh/authorized_keys
echo "$PUBLIC_KEY_2" >> /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys
chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys

# Install Nginx
echo "Installing Nginx..."
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Install Certbot
echo "Installing Certbot..."
sudo apt install -y certbot python3-certbot-nginx | sudo debconf-set-selections

# Download Nginx configs from GitHub
echo "Downloading Nginx configs from GitHub..."
sudo curl -L -o /etc/nginx/sites-available/gearment https://raw.githubusercontent.com/gearment-th1enlm02/gearment-terraform/main/templates/fe-nginx.conf
sudo curl -L -o /etc/nginx/sites-available/gearment-api https://raw.githubusercontent.com/gearment-th1enlm02/gearment-terraform/main/templates/be-nginx.conf
sudo ln -s /etc/nginx/sites-available/gearment /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/gearment-api /etc/nginx/sites-enabled/

# Test and reload Nginx
echo "Testing Nginx configuration..."
sudo rm -f /etc/nginx/sites-enabled/default
if ! sudo nginx -t; then
    echo "Nginx configuration test failed. Check /var/log/nginx/error.log"
    cat /etc/nginx/sites-available/gearment
    cat /etc/nginx/sites-available/gearment-api
    exit 1
fi
echo "Reloading Nginx..."
sudo systemctl reload nginx

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

# Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Download docker-compose.yml from GitHub
echo "Downloading docker-compose.yml from GitHub..."
sudo mkdir -p /home/ubuntu/app
sudo curl -L -o /home/ubuntu/app/docker-compose.yml https://raw.githubusercontent.com/gearment-th1enlm02/gearment-terraform/main/templates/docker-compose.yml

# Set up app directories
echo "Setting up Docker Compose directories..."
sudo mkdir -p /home/ubuntu/app/mongo_data /home/ubuntu/app/gearment-app /home/ubuntu/app/gearment-ui
sudo chown -R ubuntu:ubuntu /home/ubuntu/app
sudo docker-compose -f /home/ubuntu/app/docker-compose.yml up -d mongo
