data "aws_vpc" "default" {
  default = true
}

resource "aws_key_pair" "chatbot" {
  key_name   = "ai-chatbot-key"
  public_key = file(pathexpand("~/.ssh/ai-chatbot-key.pub"))
}

resource "aws_security_group" "chatbot" {
  name        = "ai-chatbot-sg"
  description = "Firewall for the ai-chatbot k3s server"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Chatbot app"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ai-chatbot-sg"
  }
}
