# Find the latest Ubuntu 22.04 image (the "AMI" you pick on the launch screen)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical, the makers of Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# The server itself
resource "aws_instance" "chatbot" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "m7i-flex.large"
  key_name               = aws_key_pair.chatbot.key_name
  vpc_security_group_ids = [aws_security_group.chatbot.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  # Runs once, the first time the server boots: installs k3s
  user_data = <<-USERDATA
    #!/bin/bash
    set -e
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --write-kubeconfig-mode 644" sh -
    until [ -f /etc/rancher/k3s/k3s.yaml ]; do sleep 2; done
    mkdir -p /home/ubuntu/.kube
    cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
    chown -R ubuntu:ubuntu /home/ubuntu/.kube
  USERDATA

  tags = {
    Name = "ai-chatbot-server"
  }
}
