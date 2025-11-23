# 1. Створення VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# 2. Створення Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# 3. Створення публічних підмереж (по одній на AZ)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true # Публічні IP для інстансів

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
  }
}

# 4. Створення приватних підмереж (по одній на AZ)
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
  }
}

# 5. Створення Elastic IP для NAT Gateway (по одному на AZ)
resource "aws_eip" "nat_eip" {
  count  = length(var.public_subnets)
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip-${count.index + 1}"
  }
}

# 6. Створення NAT Gateway (по одному на AZ, у публічній підмережі)
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.vpc_name}-nat-${count.index + 1}"
  }
  # Залежність від IGW, щоб забезпечити його існування
  depends_on = [aws_internet_gateway.igw]
}
