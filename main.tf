# configure aws provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}


resource "aws_vpc" "Deploy5" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "Deploy5_VPC"
  }
}

output "vpc_id" {
  value = aws_vpc.Deploy5.id
}



#create subnets
resource "aws_subnet" "Pub_sub_a" {
  vpc_id     = aws_vpc.Deploy5.id
  availability_zone = "${var.region}a"
  cidr_block = var.pub_subneta_cidr
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "dep5_pub_sub_a"
    vpc : "Deploy5_VPC"
    az : "${var.region}a"
  }
}

output "pub_subneta_id" {
  value = aws_subnet.Pub_sub_a.id
}

resource "aws_subnet" "Pub_sub_b" {
  vpc_id     = aws_vpc.Deploy5.id
  availability_zone = "${var.region}b"
  cidr_block = var.pub_subnetb_cidr
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "dep5_pub_sub_b"
    vpc : "Deploy5_VPC"
    az : "${var.region}b"
  }
}

output "pub_subnetb_id" {
  value = aws_subnet.Pub_sub_b.id
}

#create route table
resource "aws_route_table" "Deploy5_rt" {
  vpc_id = aws_vpc.Deploy5_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_deploy5.id
  }

  tags = {
    Name : "Deploy5_rt"
    vpc : "Deploy5"
  }
}

#create route table association
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.Pub_sub_a.id
  route_table_id = aws_route_table.Deploy5_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.Pub_sub_b.id
  route_table_id = aws_route_table.Deploy5_rt.id
}

#create internet gateway
resource "aws_internet_gateway" "Dep5_igw" {
  vpc_id = aws_vpc.Deploy5.id

  // igw config

  tags = {
    Name = "Dep5_igw"
  }

}




 #create instance
resource "aws_instance" "Dep5_instance1" {

  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.terraform_dep5.id]
  subnet_id = aws_subnet.Pub_sub_a.id
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("jenkins.sh")}"

  tags = {
    Name : var.app_server
    vpc : "Deploy5_VPC"
    az : "${var.region}a"
  }
}


 #create instance
resource "aws_instance" "Dep5_instance2" {

  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.terraform_dep5.id]
  subnet_id = aws_subnet.Pub_sub_b.id 
  associate_public_ip_address = true
  key_name = var.key_name 
   
  user_data = "${file("software.sh")}"

  tags = {
    Name : var.web_server
    vpc : "Deploy5_VPC"
    az : "${var.region}b"
  }
}  



# create security group

resource "aws_security_group" "terraform_dep5" {
  name        = "terraform_dep5"
  description = "open ssh traffic"
  vpc_id = aws_vpc.Deploy5.id

  ingress {
     from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : "dep5sg"
    "Terraform" : "true"
  }

}

output "jenkins_app_server" {
  value = aws_instance.Dep5_instance1.public_ip
}

output "web_application_server_ip" {
  value = aws_instance.Dep5_instance2.public_ip
}
