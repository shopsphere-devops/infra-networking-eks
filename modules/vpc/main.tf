# Creates a VPC with the CIDR block specified in var.vpc_cidr.
# Enables DNS support and hostnames as per variables.
# Tags the VPC with a name and any additional tags.
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# Creates an Internet Gateway and attaches it to the VPC.
# Tags it with a name and additional tags.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-igw"
    },
    var.tags
  )
}

# Creates multiple public subnets (one per entry in var.public_subnets).
# Each subnet is in a specific AZ and has its own CIDR block.
# Maps public IPs on launch.
# Tags for Kubernetes and ELB integration.
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      Name = "${var.name}-public-${var.azs[count.index]}"
      Type = "public"
      "kubernetes.io/cluster/shopsphere-dev-eks" = "owned"
      "kubernetes.io/role/elb" = "1"
    },
    var.public_subnet_tags
  )
}

# Creates multiple private subnets (one per entry in var.private_subnets).
# Each subnet is in a specific AZ and has its own CIDR block.
# Tags for Kubernetes and internal ELB integration.
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    {
      Name = "${var.name}-private-${var.azs[count.index]}"
      Type = "private"
      "kubernetes.io/cluster/shopsphere-dev-eks" = "owned"
      "kubernetes.io/role/internal-elb" = "1"
    },
    var.private_subnet_tags
  )
}

# Allocates an Elastic IP for the NAT Gateway.
resource "aws_eip" "nat" {
  tags = merge(
    {
      Name = "${var.name}-nat-eip"
    },
    var.tags
  )
}

# Creates a NAT Gateway in the first public subnet.
# Uses the Elastic IP created above.
# Allows private subnets to access the internet (for updates, etc.) without exposing them directly.
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    {
      Name = "${var.name}-nat"
    },
    var.tags
  )
}

# Creates a route table for public subnets.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-public-rt"
      Type = "public"
    },
    var.tags
  )
}

# Adds a default route (0.0.0.0/0) to the Internet Gateway in the public route table.
# This allows public subnets to reach the internet.
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Associates each public subnet with the public route table.
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Creates a route table for private subnets.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-private-rt"
      Type = "private"
    },
    var.tags
  )
}

# Adds a default route (0.0.0.0/0) to the NAT Gateway in the private route table.
# This allows private subnets to access the internet via the NAT Gateway.
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

# Associates each private subnet with the private route table.
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}