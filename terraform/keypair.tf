resource "aws_key_pair" "devops_key_pair" {
  key_name   = var.key_name
  public_key = file("../.ssh/devops-key-pair.pub")
}