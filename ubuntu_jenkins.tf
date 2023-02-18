provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "ubuntu" {
  key_name   = "ubuntu"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCiMl4o0iat8xgTG93yPOXt5mVCREIvY7LNrLvkGYEsliYhjbxO6wWJYQn6llBqkcKVOjOgJxHPFQ57g5ByXXUko1Z4ch02JFMP8gQY1Yp3hRuumlMF/BDlyFeCCt76kVJycZAVBUrNHccrgI9qd72iCusUK+kx0p2AkrIVQ4lj+l7/B7pOYYLjaBZC+6IIQj2JNg9NWYzJZSGUn861Gn78xCmCZSKaGMc54gl8+LW+ihuAPA1nXz/T9jwSkhX3LaeLxZ5OmMly97ql5S4dc2hSEu8kIJxMSPkymWY+70y5rZl4s0cvaMbCZ4gUwWjnAg2UGt/MB6SSFgKAy/JiFc2h eitan_exam_key"
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
    Name = "eitan_exam_sg"
  }
}


resource "aws_instance" "jenkins-ubuntu" {
  key_name      = aws_key_pair.ubuntu.key_name
  ami           = "ami-00ddb0e5626798373"
  instance_type = "t2.micro"
  user_data = file("install_ansible.sh")

  tags = {
    Name = "jenkins-ubuntu-exam"
  }

  vpc_security_group_ids = [
    aws_security_group.ubuntu.id
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("eitan_exam_key.pem")
    host        = self.public_ip
  }

}


output "jenkins_public_ip" {
 value = [aws_instance.jenkins-ubuntu.*.public_ip]
}
