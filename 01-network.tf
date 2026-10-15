resource "aws_vpc" "vpc_3_tires_project"{
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "vpc_3-tiers"
    }
}

resource "aws_subnet" "public_subnet_a"{
    vpc_id = aws_vpc.vpc_3_tires_project.id
    availability_zone = "us-east-1a"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "public_subnet_a_3-tiers"
    }
}

resource "aws_subnet" "private_app_subnet_a"{
    vpc_id = aws_vpc.vpc_3_tires_project.id
    availability_zone = "us-east-1a"
    cidr_block = "10.0.11.0/24"
    tags = {
        Name = "private_app_subnet_a_3-tiers"
    }
}

resource "aws_subnet" "private_db_subnet_a"{
    vpc_id = aws_vpc.vpc_3_tires_project.id
    availability_zone = "us-east-1a"
    cidr_block = "10.0.21.0/24"
    tags = {
        Name = "private_db_subnet_a_3-tiers"
    }
}

resource "aws_subnet" "public_subnet_b"{
    vpc_id = aws_vpc.vpc_3_tires_project.id
    availability_zone = "us-east-1b"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "public_subnet_b_3-tiers"
    }
}

resource "aws_subnet" "private_app_subnet_b"{
    vpc_id = aws_vpc.vpc_3_tires_project.id
    availability_zone = "us-east-1b"
    cidr_block = "10.0.12.0/24"
    tags = {
        Name = "private_app_subnet_b_3-tiers"
    }
}

resource "aws_subnet" "private_db_subnet_b"{
    vpc_id = aws_vpc.vpc_3_tires_project.id
    availability_zone = "us-east-1b"
    cidr_block = "10.0.22.0/24"
    tags = {
        Name = "private_db_subnet_b_3-tiers"
    }
}

resource "aws_internet_gateway" "igw_3-tiers"{
    vpc_id = aws_vpc.vpc_3_tires_project.id
    tags = {
        Name = "igw_3-tiers"
    }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_3_tires_project.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_3-tiers.id
  }
    tags = {
        Name = "public_rt_3-tiers"
    }
}

resource "aws_route_table_association" "public_rt_association_a"{
    route_table_id = aws_route_table.public_rt.id
    subnet_id = aws_subnet.public_subnet_a.id
}

resource "aws_route_table_association" "public_rt_association_b"{
    route_table_id = aws_route_table.public_rt.id
    subnet_id = aws_subnet.public_subnet_b.id
}

resource "aws_eip" "eip_nat_3-tiers" {
  domain = "vpc"
    tags = {
        Name = "eip_nat_3-tiers"
    }
}

resource "aws_nat_gateway" "natgw_3-tiers" {
    allocation_id = aws_eip.eip_nat_3-tiers.id
    subnet_id = aws_subnet.public_subnet_a.id
    tags = {
      Name = "natgw_3-tiers"
    }

    depends_on = [aws_internet_gateway.igw_3-tiers]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_3_tires_project.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw_3-tiers.id
  }
    tags = {
        Name = "private_rt_3-tiers"
    }
}

resource "aws_route_table_association" "private_rt_association_a"{
    route_table_id = aws_route_table.private_rt.id
    subnet_id = aws_subnet.private_app_subnet_a.id
}

resource "aws_route_table_association" "private_rt_association_b"{
    route_table_id = aws_route_table.private_rt.id
    subnet_id = aws_subnet.private_app_subnet_b.id
}