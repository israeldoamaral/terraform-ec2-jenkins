# terraform-ec2-jenkins
- [x] Status:  Ainda em desenvolvimento.
###
### Projeto para criar um servidor Jenkins na AWS composto dos módulos Vpc, Security_Group, ssh-key e EC2.
Para utilizar este projeto são necessários os seguintes arquivos especificados logo abaixo:

   <summary>versions.tf - Arquivo com as versões dos providers.</summary>

```hcl
terraform {
    required_version = ">= 0.15.4"

    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = ">= 3.0"
        }
    }
 }
```
#
<summary>main.tf - Arquivo que irá consumir os módulos para criar a infraestrutura necessária para o projeto.</summary>

```hcl
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
```
#
<summary>variables.tf - Arquivo que contém as variáveis que o módulo irá utilizar e pode ter os valores alterados de acordo com a necessidade.</summary>

```hcl
variable "region" {
  type        = string
  description = "Região na AWS"
  default     = "us-east-1"
}

variable "cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "count_available" {
  type        = number
  description = "Numero de Zonas de disponibilidade"
  default     = 2
}

variable "tag_vpc" {
  description = "Tag Name da VPC"
  type        = string
  default     = "VPC-name"
}

variable "tag_igw" {
  description = "Tag Name do internet gateway"
  type        = string
  default     = "gw-name"
}

variable "tag_rtable" {
  description = "Tag Name das route tables"
  type        = string
  default     = "rt-name"
}

variable "nacl" {
  description = "Regras de Network Acls AWS"
  type        = map(object({ protocol = string, action = string, cidr_blocks = string, from_port = number, to_port = number }))
  default = {
    100 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 22, to_port = 22 }
    105 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 80, to_port = 80 }
    110 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 443, to_port = 443 }
    150 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 1024, to_port = 65535 }
  }
}

```
#
<summary>outputs.tf - Outputs de recursos que serão utilizados em outros módulos.</summary>

```hcl
output "vpc" {
  description = "Idendificador da VPC"
  value       = module.network.vpc
}

output "public_subnet" {
  description = "Subnet public "
  value       = module.network.public_subnet
}

output "private_subnet" {
  description = "Subnet private "
  value       = module.network.private_subnet
}

```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | github.com/marcio-machado76/terraform_aws_vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr"></a> [cidr](#input\_cidr) | CIDR da VPC, exemplo "10.0.0.0/16" | `string` | `" "` | no |
| <a name="input_count_available"></a> [count\_available](#input\_count\_available) | Numero de Zonas de disponibilidade | `number` | `2` | no |
| <a name="input_nacl"></a> [nacl](#input\_nacl) | Regras de Network Acls AWS | `map(object)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Região na AWS, exemplo "us-east-1" | `string` | `" "` | no |
| <a name="input_tag_igw"></a> [tag\_igw](#input\_tag\_igw) | Tag Name do internet gateway | `string` | `""` | no |
| <a name="input_tag_rtable"></a> [tag\_rtable](#input\_tag\_rtable) | Tag Name das route tables | `string` | `""` | no |
| <a name="input_tag_vpc"></a> [tag\_vpc](#input\_tag\_vpc) | Tag Name da VPC | `string` | `""` | no |

## Outputs

No outputs.
#
## Como usar.
  - Para utilizar localmente crie os arquivos descritos no começo deste tutorial, main.tf, versions.tf, variables.tf e outputs.tf.
  - Após criar os arquivos, atente-se aos valores default das variáveis, pois podem ser alterados de acordo com sua necessidade. 
  - A variável `count_available` define o quantidade de zonas de disponibilidade, públicas e privadas que seram criadas nessa Vpc.
  - Certifique-se que possua as credenciais da AWS - **`AWS_ACCESS_KEY_ID`** e **`AWS_SECRET_ACCESS_KEY`**.

### Comandos
Para consumir os módulos deste repositório é necessário ter o terraform instalado ou utilizar o container do terraform dentro da pasta do seu projeto da seguinte forma:

* `docker run -it --rm -v $PWD:/app -w /app --entrypoint "" hashicorp/terraform:light sh` 
    
Em seguida exporte as credenciais da AWS:

* `export AWS_ACCESS_KEY_ID=sua_access_key_id`
* `export AWS_SECRET_ACCESS_KEY=sua_secret_access_key`
    
Agora é só executar os comandos do terraform:

* `terraform init` - Comando irá baixar todos os modulos e plugins necessários.
* `terraform fmt` - Para verificar e formatar a identação dos arquivos.
* `terraform validate` - Para verificar e validar se o código esta correto.
* `terraform plan` - Para criar um plano de todos os recursos que serão utilizados.
* `terraform apply` - Para aplicar a criação/alteração dos recursos. 
* `terraform destroy` - Para destruir todos os recursos que foram criados pelo terraform. 
