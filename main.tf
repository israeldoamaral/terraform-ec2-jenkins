provider "aws" {
  region = var.region
}


module "network" {
  source          = "git::https://github.com/israeldoamaral/terraform-vpc-aws"
  region          = var.region
  cidr            = var.cidr
  count_available = var.count_available
  vpc             = module.network.vpc
  tag_vpc         = "Jenkins" #var.tag_vpc
  nacl            = var.nacl
}


module "security_group" {
  source  = "git::https://github.com/israeldoamaral/terraform-sg-aws"
  vpc     = module.network.vpc
  sg-cidr = var.sg-cidr
  tag-sg = "Jenkins"

}


module "ssh-key" {
  source    = "git::https://github.com/israeldoamaral/terraform-sshkey-aws"
  namespace = "Jenkins" #var.namespace

  depends_on = [
    module.network
  ]
}


module "ec2" {
  source         = "git::https://github.com/israeldoamaral/terraform-ec2-aws"
  ami_id         = "ami-04505e74c0741db8d"
  instance_type  = "t2.micro"
  subnet_id      = module.network.public_subnet[0]
  security_group = module.security_group.security_group_id
  key_name       = module.ssh-key.key_name
  userdata       = "files/install_jenkins_docker.sh"
  tag_name       = "Jenkins"

  depends_on = [
    module.network
  ]
  
}


resource "null_resource" "example_provisioner" {
  triggers = {
    public_ip = module.ec2.public_ip
  }

  connection {
    type  = "ssh"
    host  = module.ec2.public_ip
    user  = "ubuntu"
    private_key = file("${module.ssh-key.key_name}.pem")
    agent = true
  }

  // copy our example script to the server
  provisioner "file" {
    source      = "files/get-InitialPassword.sh"
    destination = "/tmp/get-InitialPassword.sh"
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/get-InitialPassword.sh",
      "sudo /tmp/get-InitialPassword.sh > /tmp/InitialPassword",
    ]
  }

  provisioner "local-exec" {
    # copy the public-ip file back to CWD, which will be tested
    command = "scp -i ${module.ssh-key.key_name}.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${module.ec2.public_ip}:/tmp/InitialPassword InitialPassword"
  }

  depends_on = [
    module.ec2
  ]
}
