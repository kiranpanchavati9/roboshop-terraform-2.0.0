# Terraform configuration for AWS resources
# Security group, EC2 instance, and Route 53 record for the frontend application 

resource "aws_security_group" "allow_ports_firewall_roboshop" {
  name        = "allow_ports_firewall_roboshop"
  description = "Allow roboshop firewall inbound traffic and all outbound traffic"
  vpc_id      = "vpc-0fcbf944165ec4597"
  tags = {
    Name = "allow_ports_firewall_roboshop"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ports_firewall_roboshop" {
  security_group_id = aws_security_group.allow_ports_firewall_roboshop.id
  cidr_ipv4         = aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4.cidr_ipv4
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ports_firewall_roboshop.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ports_firewall_roboshop.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

## Create Multiple EC2 instances 

resource "aws_instance" "instance" {
  count = 9 
  ami           = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.allow_ports_firewall_roboshop.name]
  key_name     = var.key_name
  tags = {
    Name = var.components[count.index]
  }
}

resource "aws_route53_record" "a-records" {
  count = 9
  zone_id = var.zone_id
  name    = "${var.components[count.index]}-dev"
  type    = var.type
  ttl     = var.ttl
  records = [aws_instance.instance[count.index].public_ip]
}
