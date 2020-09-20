provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "available" {}

data "aws_ami" "packer_image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["example-ami-packer"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["771329597953"] #Canonical

}

resource "aws_key_pair" "tecotest_key" {
  key_name   = "teco-test-tf-key"
  public_key = file(var.my_public_key)
}

data "template_file" "init" {
  template = file("${path.module}/userdata.tpl")
}

resource "aws_instance" "teco_test_instance" {
  count                  = 2
  ami                    = data.aws_ami.centos.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.tecotest_key.id
  vpc_security_group_ids = [var.security_group]
  subnet_id              = element(var.subnets, count.index )
  user_data              = data.template_file.init.rendered

  tags = {
    Name = "teco_test_instance-${count.index + 1}"
  }
}

resource "aws_ebs_volume" "teco_test_ebs" {
  count             = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]
  size              = 1
  type              = "gp2"
}

resource "aws_volume_attachment" "my-vol-attach" {
  count        = 2
  device_name  = "/dev/xvdh"
  instance_id  = aws_instance.teco_test_instance.*.id[count.index]
  volume_id    = aws_ebs_volume.teco_test_ebs.*.id[count.index]
  force_detach = true
}