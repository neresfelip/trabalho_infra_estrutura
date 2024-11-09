provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "note_dell_key" {
  key_name   = "note_dell_key"
  public_key = file("~/.ssh/id_ed25519")
}

resource "aws_security_group" "my_sg" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

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

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_instance" "unifor_ubuntu" {
  ami             = "ami-0866a3c8686eaeeba"
  instance_type   = "t2.micro"
  key_name        = "${aws_key_pair.note_dell_key.key_name}"
  count           = 1
  tags           = {
    Name = "TerraformEC2__Unifor__Ubuntu"
    type = "universidade"
  }
  security_groups = ["${aws_security_group.my_sg.name}"]

  # Initial setup only
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = self.public_ip
    }
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}

output "PUBLIC_IP" {
  value = aws_instance.unifor_ubuntu[0].public_ip
}