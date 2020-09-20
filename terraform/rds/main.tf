provider "aws" {
  region = "us-west-2"
}


resource "aws_db_instance" "teco_test_sql" {
  instance_class = var.db_instance
  engine = "mysql"
  engine_version = "5.7"
  multi_az = true
  storage_type = "gp2"
  allocated_storage = 20
  name = "tecotestrds"
  username = "admin"
  password = "admin123"
  apply_immediately = "true"
  backup_retention_period = 10
  backup_window = "09:46-10:16"
  db_subnet_group_name = aws_db_subnet_group.teco_test_rds_db_subnet.name
  vpc_security_group_ids = [aws_security_group.teco_test_rds_sg.id]
}

resource "aws_db_subnet_group" "teco_test_rds_db_subnet" {
  name = "teco_test_rds_db_subnet"
  subnet_ids = [var.rds_subnet1,var.rds_subnet2]
}

resource "aws_security_group" "teco_test_rds_sg" {
  name = "teco_test_rds_sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "teco_test_rds_sg_rule" {
  from_port = 3306
  protocol = "tcp"
  security_group_id = aws_security_group.teco_test_rds_sg.id
  to_port = 3306
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_rule" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.teco_test_rds_sg.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}