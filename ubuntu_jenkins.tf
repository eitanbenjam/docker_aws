provider "aws" {
  profile = "default"
  region  = "us-west-1"
}

resource "aws_key_pair" "ubuntu" {
  key_name   = "ubuntu"
  public_key = file("tikal_key.pem")
}

resource "aws_security_group" "ubuntu" {
  name        = "ubuntu-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tikal"
  }
}


resource "aws_instance" "jenkins-ubuntu" {
  key_name      = aws_key_pair.ubuntu.key_name
  ami           = "ami-0ac73f33a1888c64a"
  instance_type = "t2.micro"
  user_data = file("install_ansible.sh")

  tags = {
    Name = "tikal"
  }

  vpc_security_group_ids = [
    aws_security_group.ubuntu.id
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("tikal_key.pem")
    host        = self.public_ip
  }

}

resource "aws_eip" "ubuntu" {
  vpc      = true
  instance = aws_instance.jenkins-ubuntu.id
}

