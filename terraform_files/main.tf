resource "aws_security_group" "devops_project_2_app_sg" {
  name        = "devops-project-2-app-sg"
  description = "Allow SSH, HTTP, HTTPS for Docker Compose App"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}


resource "aws_instance" "app_server" {
  ami                    = "ami-0cf10cdf9fcd62d37"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.devops_project_2_app_sg.id]
  key_name               = "My_Key"

  root_block_device {
    volume_size = 15
    volume_type = "gp2"
  }

  tags = {
    Name = "APP-SERVER"
  }

  user_data = <<-EOF
    #!/bin/bash
    # Wait for EC2 initialization
    sleep 60
    
    # Update system packages
    sudo yum update -y
    
    # Install Docker
    sudo yum install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    
    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Install Git
    sudo yum install git -y
    
    # Create project directory
    mkdir -p /opt/devops-project
    
    # Set permissions
    sudo chown -R ec2-user:ec2-user /opt/devops-project
  EOF

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      private_key = file("./My_Key.pem")
      user        = "ec2-user"
      host        = self.public_ip
    }

    inline = [
      "sleep 120",
      "docker --version",
      "docker-compose --version",
    ]
  }
}

output "APP_SERVER_PUBLIC_IP" {
  value = aws_instance.app_server.public_ip
}

output "APP_SERVER_PRIVATE_IP" {
  value = aws_instance.app_server.private_ip
}

output "ACCESS_YOUR_APP_HERE" {
  value = "http://${aws_instance.app_server.public_ip}:80"
}
