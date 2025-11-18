resource "aws_security_group" "app_sg" {
  name        = "${var.project}-sg"
  description = "Allow internal app traffic; SSH from admin IP only"
  vpc_id      = aws_vpc.main.id

  # Replace x.x.x.x/32 with your admin IP or use 0.0.0.0/0 only for learning (NOT recommended)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from admin IP"
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "App port internal"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-sg" }
}