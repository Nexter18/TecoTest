provider "aws" {
  region = "us-west-2"
}

resource "aws_launch_configuration" "teco_test_launch_config" {
  image_id        = "ami-01ed306a12b7d1c96" #Get the ID from Packer automation
  instance_type   = "t2.micro"
  security_groups = [var.security_group]

  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo "Hello, from Terraform" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "teco_test_as_group" {
  launch_configuration = aws_launch_configuration.teco_test_launch_config.name
  vpc_zone_identifier  = [var.subnet1,var.subnet2]
  health_check_type    = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "teco-test-asg"
    propagate_at_launch = true
  }
}