provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow SSH"
  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "example" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data              = file("user_data.sh")

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name = "MyEC2Instance"
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "[ec2]" > inventory.ini
      echo "${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.private_key_path}" >> inventory.ini
      
    EOT
    
  }
}
