# terraform-ec2-jenkins
- [x] Status:  Ainda em desenvolvimento.
###
### Projeto para criar um servidor Jenkins na AWS composto dos módulos Vpc, Security_Group, ssh-key e EC2.

#
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

#
## Modulos Utilizados

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](https://github.com/israeldoamaral/terraform-vpc-aws) | github.com/israeldoamaral/terraform-vpc-aws | n/a |
| <a name="module_security_group"></a> [security_group](https://github.com/israeldoamaral/terraform-sg-aws) | github.com/israeldoamaral/terraform-sg-aws | n/a |
| <a name="module_ssh-key"></a> [ssh-key](https://github.com/israeldoamaral/terraform-sshkey-aws) | github.com/israeldoamaral/terraform-sshkey-aws | n/a |
| <a name="module_ec2"></a> [ec2](https://github.com/israeldoamaral/terraform-ec2-aws) | github.com/israeldoamaral/terraform-ec2-aws | n/a |

#
## Inputs 

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | Região na AWS onde sera criado toda a infra | `string` | `"us-east-1"` | yes |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | CIDR block da VPC.  | `string` | `"10.0.0.0/16"` | yes |
| <a name="input_count_available"></a> [count\_available](#input\_count\_available) | Numero de Zonas de disponibilidade | `number` | `2` | yes |
| <a name="input_nacl"></a> [nacl](#input\_nacl) | Regras de Network Acls AWS | `map(object)` | n/a | yes |
| <a name="input_tag_vpc"></a> [tag\_vpc](#input\_tag\_vpc) | Tag Name da VPC | `string` | `""` | yes |
| <a name="input_sg-cidr"></a> [sg-cidr](#input\sg-cidr) | Portas a serem liberadas para a instancia | `map(object)` | `""` | yes |
| <a name="input_namespace"></a> [namespace](#input\namespace) | Nome da chave ssh  | `string` | `""` | yes |
| <a name="input_ami_id"></a> [ami_id](#input\ami_id) | ID da AMI  | `string` | `""` | yes |
| <a name="input_instance_type"></a> [instance_type](#input\instance_type) | Nome da Instancia ec2  | `string` | `""` | yes |
| <a name="input_userdata"></a> [userdata](#input\userdata) | Caminho/arquivo que será aplicado para instalar o Jenkins  | `string` | `""` | yes |
| <a name="input_tag_name"></a> [tag_name](#input\tag_name) | Nome da Tag para instancia ec2  | `string` | `""` | yes |


#
## Como usar.
  - Para utilizar clone o repositório.
  - Acesse a pasta que foi clonada.
  - Após clonar o repositŕio, altere os valores default das variáveis, pois podem ser alterados de acordo com sua necessidade. 
  - A variável `count_available` define o quantidade de zonas de disponibilidade, públicas e privadas que seram criadas nessa Vpc.
  - Certifique-se que possua as credenciais da AWS - **`AWS_ACCESS_KEY_ID`** e **`AWS_SECRET_ACCESS_KEY`**.

### Comandos
- Exporte as credenciais da AWS:
* `export AWS_ACCESS_KEY_ID=sua_access_key_id`
* `export AWS_SECRET_ACCESS_KEY=sua_secret_access_key`

- Clone o repositório:
* `git clone https://github.com/israeldoamaral/terraform-ec2-jenkins.git`

- Acesse a pasta clonada:
* `cd terraform-ec2-jenkins`

Para iniciar é necessário ter o terraform instalado ou utilizar o container do terraform dentro da pasta do seu projeto da seguinte forma:
* `docker run -it --rm -v $PWD:/app -w /app --entrypoint "" hashicorp/terraform:light sh` 
    
Agora é só executar os comandos do terraform:
- Comando irá baixar todos os modulos e plugins necessários.
* `terraform init` 

- Para verificar e formatar a identação dos arquivos.
* `terraform fmt` 

- Para verificar e validar se o código esta correto.
* `terraform validate` 

- Para criar um plano de todos os recursos que serão utilizados.
* `terraform plan --out plano` 

- Para aplicar a criação/alteração dos recursos. 
* `terraform apply plano` 

#
## Outputs

- Será retornado após a criação os valores de exemplo:

Url_Jenkins = "34.207.86.109:8080"

ec2_ip = "34.207.86.109"

key_name = "Jenkins-key"

private_subnet = [
  "subnet-0eb121e45013f13fd",
  "subnet-0689ed2d6d0379905",
]

public_subnet = [
  "subnet-004ed3dfa620f64e9",
  "subnet-098d99002b2cfbe9d",
]

security_Group = "sg-01e0d1528e3c2c758"

ssh_keypair = <sensitive>

vpc = "vpc-09daf8cfd78900bbf"

#
## Após terminar o processo será gerado um arquivo no root da pasta chamado "InitialPassword" onde contem a chave inicial de acesso do Jenkins. Copie e acesse a url do Jenkins

   
   
- Para destruir todos os recursos que foram criados pelo terraform. 
* `terraform destroy` 
