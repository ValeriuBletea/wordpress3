# VPC

resource "aws_vpc" "wordpress-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
   enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "wordpress-vpc"
  }
}

# IGW

resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id = aws_vpc.wordpress-vpc.id

  tags = {
    Name = "wordpress-igw"
  }
}

# RT

resource "aws_route_table" "wordpess-rt" {
  vpc_id = aws_vpc.wordpress-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress_igw.id
  }

  tags = {
    Name = "wordpress-rt"
  }
}

# Public Subnets

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.wordpress-vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "wordpress-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.wordpress-vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "wordpress-public-subnet-2"
  }
}

resource "aws_subnet" "public_subnets_3" {
  vpc_id                  = aws_vpc.wordpress-vpc.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "wordpress-public-subnet-3"
  }
}

# Associate public subnets with route table
resource "aws_route_table_association" "public_subnet_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.wordpess-rt.id
}

resource "aws_route_table_association" "public_subnet_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.wordpess-rt.id
}

resource "aws_route_table_association" "public_subnet_association_3" {
  subnet_id      = aws_subnet.public_subnets_3.id
  route_table_id = aws_route_table.wordpess-rt.id
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.wordpress-vpc.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "wordpress-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
vpc_id            = aws_vpc.wordpress-vpc.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "wordpress-private-subnet-2"
  }
}
resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.wordpress-vpc.id
  cidr_block        = "10.0.9.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "wordpress-private-subnet-3"
  }
}

# Wordpress-SG

resource "aws_security_group" "ec2" {
  name   = "wordpress-sg"
  vpc_id = aws_vpc.wordpress-vpc.id


  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "wordpress-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# EC2

resource "aws_instance" "wordpress-ec2" {
  ami             = var.ami
  instance_type   = "t2.micro"
  key_name        = "ssh-key"
  user_data = file("${path.module}/wordpress.sh")
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id       = aws_subnet.public_subnet_1.id

  
  tags = {
    Name = "wordpress-ec2"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "mysql"
  description = "Allow mysql"
  vpc_id      = aws_vpc.wordpress-vpc.id

  tags = {
    Name = "mysql"
  }
}

resource "aws_security_group_rule" "allow_mysql_from_ec2" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds-sg.id
  source_security_group_id = aws_security_group.ec2.id
  description              = "Allow MySQL traffic from ec2-sg to rds-sg"
}



# RDS

resource "aws_db_instance" "mysql" {
  allocated_storage   = 20
  db_name             = "wordpressrds"
  engine              = "mysql"
  storage_type        = "gp2"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = "adminadmin"
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]

  tags = {
    Name = "My DB subnet group"
  }
}