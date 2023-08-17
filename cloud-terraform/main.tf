
#LoadBalancer target-group (target les EC2) - LoadBalancer sg- LoadBalancer - Certificate ACM - LoadBalancer listener
resource "aws_lb_target_group" "tg_lb" {
  name        = "tglb"
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

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 indique tous les protocoles
    cidr_blocks = ["0.0.0.0/0"]
  }

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

resource "aws_route53_record" "alias_route53_record" {
  zone_id = "Z02170383FDAMUU6TL6ZP" # a retrouver dans zone --> route 53 sur mon domaine hrazanam.net 
  name    = "hrazanam.net" # Replace with your name/domain/subdomain
  type    = "A"

  alias {
    name                   = aws_lb.my_elb.dns_name
    zone_id                = aws_lb.my_elb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener" "my_elb_listen" {
  load_balancer_arn = aws_lb.my_elb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = "arn:aws:acm:eu-west-3:587743568684:certificate/5b4d5605-3431-40ff-a8df-be9f98db7a80"  # ARN de votre certificat ACM
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_lb.arn
  }
}

#Security group EC2 
resource "aws_security_group" "web_sg" {
  name_prefix = "my_sg_web"

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 indique tous les protocoles
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH traffic From my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["86.245.147.9/32"]
  }

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




#RDS sg - RDS
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







#EFS SG - EFS - EFS Mount targets - EFS Access point
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



#Instance EC2 - ne pas oublier de generer la keypair
resource "aws_instance" "wp-web" {
	depends_on = [local_file.env_file]
  ami           = "ami-05b5a865c3579bbc4" #Ubuntu
  instance_type = "t2.micro"
	key_name = "wp-keypair-mac"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "wp-web"
  }


	provisioner "remote-exec" {
    inline = [
			"mkdir /home/ubuntu/app",
    ]
		connection {
  	   type        = "ssh"
  	   user        = "ubuntu"  # Utilisateur SSH de l'instance EC2
  	   private_key = file("wp-keypair-mac.pem")  # Chemin vers votre clé privée
  	   host        = self.public_ip  # L'adresse IP publique de l'instance EC2
			 insecure    = true
  	}
  }

	provisioner "file" {
    source      = "../inception/"  # Chemin local du dossier que vous souhaitez copier
    destination = "/home/ubuntu/app"  # Chemin sur l'instance EC2
		connection {
  	   type        = "ssh"
  	   user        = "ubuntu"  # Utilisateur SSH de l'instance EC2
  	   private_key = file("wp-keypair-mac.pem")  # Chemin vers votre clé privée
  	   host        = self.public_ip  # L'adresse IP publique de l'instance EC2
			 insecure    = true
  	}
  }

	provisioner "remote-exec" {
    inline = [
			"sudo apt-get update",
			"sudo apt-get install -y ca-certificates curl gnupg",
			"sudo install -y -m 0755 -d /etc/apt/keyrings",
			"curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
			"sudo chmod a+r /etc/apt/keyrings/docker.gpg",
			"echo \\",
      "\"deb [arch=\\\"$(dpkg --print-architecture)\\\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \\",
      "\\\"$(. /etc/os-release && echo \\\"$VERSION_CODENAME\\\")\\\" stable\\\" | \\",
      "sudo tee /etc/apt/sources.list.d/docker.list > /dev/null\"",
			"sudo apt-get update",
			"sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
			"sudo apt install -y make",
			"sudo apt install -y docker-compose"
    ]
		connection {
  	   type        = "ssh"
  	   user        = "ubuntu"  # Utilisateur SSH de l'instance EC2
  	   private_key = file("wp-keypair-mac.pem")  # Chemin vers votre clé privée
  	   host        = self.public_ip  # L'adresse IP publique de l'instance EC2
			 insecure    = true
  	}
  }

#lancement docker-compose
	provisioner "remote-exec" {
    inline = [
			"cd /home/ubuntu/app",
			"sudo make",
    ]
		connection {
  	   type        = "ssh"
  	   user        = "ubuntu"  # Utilisateur SSH de l'instance EC2
  	   private_key = file("wp-keypair-mac.pem")  # Chemin vers votre clé privée
  	   host        = self.public_ip  # L'adresse IP publique de l'instance EC2
			 insecure    = true
  	}
  }

#installation efs utils - driver to access efs
	provisioner "remote-exec" {
    inline = [
			"cd /",
			"sudo apt-get update",
			"sudo apt-get -y install git binutils",
			"sudo git clone https://github.com/aws/efs-utils",
			"cd /efs-utils",
			"sudo ./build-deb.sh",
			"sudo apt-get -y install ./build/amazon-efs-utils*deb",
    ]
		connection {
  	   type        = "ssh"
  	   user        = "ubuntu"  # Utilisateur SSH de l'instance EC2
  	   private_key = file("wp-keypair-mac.pem")  # Chemin vers votre clé privée
  	   host        = self.public_ip  # L'adresse IP publique de l'instance EC2
			 insecure    = true
  	}
  }

#Montage EFS
	provisioner "remote-exec" {
    inline = [
			"cd /",
			"echo \"${aws_efs_file_system.efs_wp.id} /home/ubuntu/data efs _netdev,tls,accesspoint=${aws_efs_access_point.access_point_efs.id} 0 0\" | sudo tee -a /etc/fstab",
			"sudo mount -fav",
    ]
		connection {
  	   type        = "ssh"
  	   user        = "ubuntu"  # Utilisateur SSH de l'instance EC2
  	   private_key = file("wp-keypair-mac.pem")  # Chemin vers votre clé privée
  	   host        = self.public_ip  # L'adresse IP publique de l'instance EC2
			 insecure    = true
  	}
  }

}

#CREATE AMI FROM INSTANCE
resource "aws_ami_from_instance" "ami-with-efs" {
  name               = "AMI with EFS"
  source_instance_id = aws_instance.wp-web.id
	depends_on = [
    aws_instance.wp-web,
  ]
}

resource "aws_launch_template" "template-with-efs" {
  name_prefix   = "web-sg-template-with-efs"
  image_id      = aws_ami_from_instance.ami-with-efs.id  # Remplacez par l'ID de votre AMI
  instance_type = "t2.micro"
	key_name = "wp-keypair-mac"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

#  block_device_mappings {
#    device_name = "/dev/sda1"
#    ebs {
#      volume_size = 30
#    }
#  }
}

#TARGET GROUP ATTACHMENT for 1st instance
resource "aws_lb_target_group_attachment" "ec2_to_tglb" {
    target_group_arn = aws_lb_target_group.tg_lb.arn
    target_id        = aws_instance.wp-web.id 
    port             = 443
}

resource "aws_autoscaling_group" "group_instance" {
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  launch_template { 
			id = aws_launch_template.template-with-efs.id
			version = aws_launch_template.template-with-efs.latest_version
	}
  vpc_zone_identifier  =  [
    "subnet-020264f77b27f822e",
    "subnet-084127b0de98ebb81",
    "subnet-003dc16ba597f595b",
  ]
	health_check_grace_period = 300
	health_check_type    = "ELB"
}

#Attach all the future instance autocreate in target group
resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  autoscaling_group_name = aws_autoscaling_group.group_instance.id
  lb_target_group_arn = aws_lb_target_group.tg_lb.arn
}

output "elb_dns_name" {
  value = aws_lb.my_elb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.my_rds.endpoint
}

