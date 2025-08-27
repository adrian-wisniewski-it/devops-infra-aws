resource "aws_instance" "devops_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  count        = var.instance_count
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  subnet_id = aws_subnet.devops_public_1.id

  tags = {
    Name = "devops-instance"
  }
}
