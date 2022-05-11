resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
  force_destroy = true
  # Trying to itterate over list of regions
  # count  = length(var.regions)
  # provider = var.regions[count.index]
}
