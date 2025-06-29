data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name              = var.key_name
  subnet_id             = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  
  associate_public_ip_address = true
  
  user_data = base64encode(templatefile("${path.root}/user_data.sh", {}))
  
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-instance"
  })
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  domain   = "vpc"
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eip"
  })
}
