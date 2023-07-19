data "aws_availability_zones" "available_zones" {
  state = "available"
}

# vpc 생성
resource "aws_vpc" "vpc" {
  tags = {
    Name = "${var.app_name}-vpc"
  }
  cidr_block = "10.20.0.0/16"
}

# ==== public network 구성 시작 ====
# public subnet 생성
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = var.subnet_count
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true # public ip 할당
  tags = {
    Name : "${var.app_name}-public-subnet-${data.aws_availability_zones.available_zones.zone_ids[count.index]}"
  }
}

# internet gateway 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  count  = 1
  tags = {
    Name : "${var.app_name}-igw"
  }
}

# route table 생성 후, internet gateway 연결
resource "aws_route_table" "public_route_table" {
  count  = 1
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name : "${var.app_name}-public-route-table"
  }

  # internet gateway 연결. aws_route resource를 별도로 정의할 수도 있음.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_internet_gateway.igw.*.id, count.index)
  }
}

# route table과 public subnet 연결
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.public_route_table.*.id, count.index)
}

# ==== public network 구성 끝 ====


# ==== private network 구성 시작 ====
# private subnet 생성
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = var.subnet_count
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  tags = {
    Name : "${var.app_name}-private-subnet-${data.aws_availability_zones.available_zones.zone_ids[count.index]}"
  }
}

# nat gateway 생성, public subnet에 위치해야함!ㅅ
resource "aws_nat_gateway" "nat_gateway" {
  count         = length(aws_subnet.private_subnet)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.nat_gateway_eip.*.id, count.index)
  tags = {
    Name : "${var.app_name}-nat-gateway-${count.index}"
  }
}

# route table 생성 후, nat gateway 연결
resource "aws_route_table" "private_route_table" {
  count  = length(aws_subnet.private_subnet)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name : "${var.app_name}-private-route-table-${count.index}"
  }

  # nat gateway 연결. aws_route resource를 별도로 정의할 수도 있음.
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway.*.id, count.index)
  }
}

# route table과 private subnet 연결
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}

# nat_gateway에 연결할 eip 생성
resource "aws_eip" "nat_gateway_eip" {
  count = length(aws_subnet.private_subnet)
  vpc   = true
  tags = {
    Name : "${var.app_name}-net-eip-${count.index}"
  }
}
# ==== private network 구성 끝 ====
