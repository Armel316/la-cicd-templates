provider "aws" {
  region = var.aws_region
}

# Récupère Ubuntu 24.04 officielle
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Génère une clé SSH locale
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Enregistre la clé publique dans AWS
resource "aws_key_pair" "deployer" {
  key_name   = "terraform-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Security Group SSH
resource "aws_security_group" "ssh" {
  name = "allow_ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Pour lab uniquement
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance EC2
resource "aws_instance" "demo" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small" #small/micro/medium
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name = "terraform-ssh-demo"
  }
}
