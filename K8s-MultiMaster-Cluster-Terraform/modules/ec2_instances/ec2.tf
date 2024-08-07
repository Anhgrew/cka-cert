resource "aws_instance" "masters" {
  count                  = var.num_masters
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_groups_ids
  user_data              = file("${path.module}/master_setup.sh")
  subnet_id              = element(var.subnet_ids, count.index % length(var.subnet_ids))
  tags = {
    Name = "K8S-Master${count.index + 1}"
  }
}

resource "aws_instance" "workers" {
  count                  = var.num_workers
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_groups_ids
  subnet_id              = element(var.subnet_ids, count.index % length(var.subnet_ids))
  user_data              = file("${path.module}/worker_setup.sh")
  tags = {
    Name = "K8S-Worker${count.index + 1}"
  }
}
