
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



resource "aws_lb" "my_elb" {
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

resource "aws_lb_listener" "my_elb" {
  load_balancer_arn = aws_lb.my_elb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_lb.arn
  }
}

resource "aws_security_group" "web_sg" {
  name_prefix = "my_sg_web"

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

  ingress {
    description     = "Allow HTTPS traffic SG LB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  tags = {
    Name = "my_sg_web"
  }
}


resource "aws_security_group" "rds_sg" {
  name_prefix = "my_sg_rds"

  ingress {
    description     = "Allow MYSQL/AURORA traffic from web sg"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "my_sg_rds"
  }
}




resource "aws_db_instance" "my_rds" {
  allocated_storage   = 10
  db_name             = "hina_db"
  engine              = "mariadb"
  engine_version      = "10.6.14"
  instance_class      = "db.t3.micro"
  username            = "hina"
  password            = "geronimo"
  skip_final_snapshot = true
}

resource "local_file" "env_file" {
  filename = "../inception/srcs/terraform.env"
  content  = "LOADBALANCER_DNS=${aws_lb.my_elb.dns_name} \nRDS_ENDPOINT=${element(split(":", aws_db_instance.my_rds.endpoint), 0)}"
}








resource "aws_security_group" "efs_sg" {
  name_prefix = "my_sg_efs"

  ingress {
    description     = "Allow my wp to access and mount my EFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "my_sg_efs"
  }
}

resource "aws_efs_file_system" "efs_wp" {
  creation_token = "my-efs-wp"
  performance_mode                = "generalPurpose"
  throughput_mode                 = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "efs_mount_target_a" {
  file_system_id = aws_efs_file_system.efs_wp.id
  subnet_id      =  "subnet-020264f77b27f822e"
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "efs_mount_target_b" {
  file_system_id = aws_efs_file_system.efs_wp.id
  subnet_id      = "subnet-084127b0de98ebb81"
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "efs_mount_target_c" {
  file_system_id = aws_efs_file_system.efs_wp.id
  subnet_id      =  "subnet-003dc16ba597f595b"
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_access_point" "access_point_efs" {
  file_system_id = aws_efs_file_system.efs_wp.id
}








output "elb_dns_name" {
  value = aws_lb.my_elb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.my_rds.endpoint
}

