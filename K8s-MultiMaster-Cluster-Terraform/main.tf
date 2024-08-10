# Include other .tf files
module "security_group" {
  source      = "./modules/security_group"
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id
}

module "ec2_instances" {
  source              = "./modules/ec2_instances"
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  key_name            = var.key_name
  security_groups_ids = [module.security_group.security_group_id]
  subnet_ids          = var.subnet_ids
  num_masters         = var.num_masters
  num_workers         = var.num_workers
  depends_on          = [module.security_group]
}

resource "null_resource" "wait_for_user_data" {
  provisioner "local-exec" {
    command = <<EOT
      while [ "$(ssh -o StrictHostKeyChecking=no -i anhdrew.pem ec2-user@${module.ec2_instances.master_ips[0]} 'test -f /tmp/user_data_success && echo success')" != "success" ]; do
        echo "Waiting for user data script to complete..."
        sleep 10
      done
      echo "User data script completed successfully."
    EOT
  }

  depends_on = [module.ec2_instances]
  triggers = {
    always_run = timestamp() # Change to any value that you want to use as a trigger
  }
}

module "load_balancer" {
  count               = var.num_masters > 1 ? 1 : 0
  source              = "./modules/load_balancer"
  vpc_id              = var.vpc_id
  security_groups_ids = [module.security_group.security_group_id]
  name                = var.alb_name
  subnet_ids          = var.subnet_ids
  type                = var.type
  master_ids          = module.ec2_instances.master_ids

  depends_on = [module.security_group, null_resource.wait_for_user_data]
}

locals {
  master_ip_or_dns = var.num_masters > 1 ? module.load_balancer[0].load_balancer_dns : module.ec2_instances.master_ips[0]
}

resource "null_resource" "initialize_kubernetes_master" {
  depends_on = [null_resource.wait_for_user_data, module.load_balancer, module.ec2_instances]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./anhdrew.pem")
    host        = module.ec2_instances.master_ips[0]
  }

  provisioner "file" {
    source      = "initialize_kubernetes.sh"
    destination = "/home/ec2-user/initialize_kubernetes.sh"

  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ec2-user/initialize_kubernetes.sh",
      "bash /home/ec2-user/initialize_kubernetes.sh ${module.ec2_instances.master_ips[0]}"
    ]
  }
  # triggers = {
  #   always_run = timestamp() # Change to any value that you want to use as a trigger
  # }
  triggers = {
    file_hash = filemd5("initialize_kubernetes.sh")
  }
}

resource "null_resource" "join_remaining_masters" {
  depends_on = [null_resource.initialize_kubernetes_master, module.load_balancer, module.ec2_instances]

  count = length(module.ec2_instances.master_ips) - 1

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./anhdrew.pem")
    host        = element(module.ec2_instances.master_ips, count.index + 1)
  }

  provisioner "file" {
    source      = "./join_kubernetes_master.sh"
    destination = "/home/ec2-user/join_kubernetes_master.sh"
  }

  provisioner "file" {
    source      = "./anhdrew.pem"
    destination = "/tmp/anhdrew.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/anhdrew.pem /home/ec2-user/anhdrew.pem",
      "sudo chmod 400 /home/ec2-user/anhdrew.pem",
      "sudo chmod +x /home/ec2-user/join_kubernetes_master.sh",
      "sudo bash /home/ec2-user/join_kubernetes_master.sh ${element(module.ec2_instances.master_ips, 0)} /home/ec2-user/anhdrew.pem"
    ]
  }

  triggers = {
    file_hash = filemd5("join_kubernetes_master.sh")
  }
}

resource "null_resource" "copy_kube_config" {
  depends_on = [null_resource.initialize_kubernetes_master, module.load_balancer]

  provisioner "local-exec" {
    command = <<EOT
      scp -o StrictHostKeyChecking=no -i ./anhdrew.pem ec2-user@${module.ec2_instances.master_ips[0]}:/home/ec2-user/.kube/config ./kubeconfig
    EOT
  }

  triggers = {
    always_run = timestamp() # Change to any value that you want to use as a trigger
  }
}
resource "null_resource" "join_worker_nodes" {
  depends_on = [null_resource.initialize_kubernetes_master, module.load_balancer, module.ec2_instances]

  count = length(module.ec2_instances.worker_ips)

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./anhdrew.pem")
    host        = element(module.ec2_instances.worker_ips, count.index)
  }

  provisioner "file" {
    source      = "./join_kubernetes_worker.sh"
    destination = "/home/ec2-user/join_kubernetes_worker.sh"
  }

  provisioner "file" {
    source      = "./anhdrew.pem"
    destination = "/tmp/anhdrew.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/anhdrew.pem /home/ec2-user/anhdrew.pem",
      "sudo chmod 400 /home/ec2-user/anhdrew.pem",
      "sudo chmod +x /home/ec2-user/join_kubernetes_worker.sh",
      "sudo bash /home/ec2-user/join_kubernetes_worker.sh ${element(module.ec2_instances.master_ips, 0)} /home/ec2-user/anhdrew.pem"
    ]
  }

  triggers = {
    file_hash = filemd5("join_kubernetes_worker.sh")
  }
}

