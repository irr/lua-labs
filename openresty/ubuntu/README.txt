# Import the GPG key
wget -qO - https://openresty.org/package/pubkey.gpg | sudo apt-key add -

# Add the OpenResty repository
echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/openresty.list

# Update the package index
sudo apt update

# Install OpenResty
sudo apt install openresty

sudo systemctl start openresty

sudo systemctl enable openresty

sudo systemctl status openresty

# Stop the global OpenResty service if it's running
sudo systemctl stop openresty
