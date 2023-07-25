
resource "aws_lb_target_group" "tg_lb" {
  name        = "tg-lb"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = "vpc-0f85db5d914df8aaf"
  target_type = "instance"
}


variable "security_group_name" {
  description = "Name of the security group"
  default     = "my-sg-lb"
}

resource "aws_security_group" "lb_sg" {
  name_prefix = var.security_group_name

  ingress {
    description = "Allow HTTPS traffic (IPv4)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTPS traffic (IPv6)"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Allow HTTP traffic (IPv4)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTP traffic (IPv6)"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}



resource "aws_lb" "elb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  subnets = [
    "subnet-020264f77b27f822e",
    "subnet-084127b0de98ebb81",
    "subnet-003dc16ba597f595b",
  ]
  security_groups = [
    aws_security_group.lb_sg.id
  ]
}

resource "aws_lb_listener" "elb" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_lb.arn
  }
}
