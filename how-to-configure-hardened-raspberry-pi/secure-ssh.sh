#! /bin/bash
# Script used to secure SSH during Raspberry Pi deployments
# Not intended for public use

set -e

mkdir ~/.ssh

cat << "_EOF" > ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCzQpX9uqDP8L2gSZNJxYEi04Y1pZWz28v4zANY5dU6M35OFzXZcRcBqi2ZxiQofgxRrX9QlAcmcPFz8/CkpPw2WgQTflm+46ZrVEZcwwGwJsJwm7QVLQLd44/xtejEvMjzsuYDjJ1q4WhEvMSleTfOrix4yP0mjn83Zk1l6AMxR5J8DDumiHsGSYfcp+1XS9x4r4HP0mS2RpIy3rcoxLoJaYEKvVTj9qdvPMK7SDymZcvuBsgObEARVr77q4qhUfTP+xR91hHNEYD9FnCHF3qQBzlTlmTwpwhH6vOdWE3uUXCug9Ugw42Zj3PW0zd5rQ7EEpD9SDLbUqajpn2M5AlhkS9OrLpnIptocetRKNI9HzyAV1KqdNiQeL7/59d4y+HuZ9y032SaNzR1fw0nYMoHzTN9d+zPvziDZ183/pwtEXZNVVGzYO1r56n3S4vLx8YCpYqiHYVQVDF8aweoHYs3dAGAfPxmQ85+45UKpFR18XSGCqCO2fwbyTGDhkxCzU= pi
_EOF

sudo sed -i -E 's/^(#)?PermitRootLogin (prohibit-password|yes)/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i -E 's/^(#)?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

printf "%s\n" "SSH secured"
