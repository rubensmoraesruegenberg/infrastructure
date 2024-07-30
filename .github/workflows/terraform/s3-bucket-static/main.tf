# Definição de um provedor AWS, é como se fosse um plugi
provider "aws"{
    region = "us-east-1"
}

#Declarar variavel bucket_name, para receber o nome do bucket e utilizar a onde se precisar.

variable "bucket_name"{
    type = string
}

# São objetos de infra estrutura, mudar permissões, mudar memória que utiliza
# esses mudam de acordo com o provider que se utiliza, nesse casa vai se utilizar os recurso da AWS
# dentro desse recurso temos dois parametros o aws_s3_bucket e static_site_bucket
# dentro das chaves vamos colocar as configurações que precisamos para criar o bucket
resource "aws_s3_bucket" "static_site_bucket"{
    # 1º Nome do bucket, coloca o prefixo + varaivel de momento de execução do 
    # terraform que é a bucket_name, assim conseguimos identificar os buckets static_site são desse prefixo
    # poderia ser o nome de uma empresa, é um bom padrão de nomenclatura
    bucket = "static_site-${var.bucket_name}"

    # criar o documento de indice e de erro, eles são .html e pode colocar o nome que precisar como
    # error.html, 404.hml
    # indice é o arquivo que vai ser carregado quando o bucket for acessado pelo link do bucket
    # Erro caso o acesse a rota e naõ tenha nenhum arquivo, esse de erro indica que não há arquivo
    website{
        index_document = "index.html"
        error_document = "404.html"
    }
    
    # Servem para organizar, categorizar, em uma empresa grande ajuda a encontrar os buckets
    tags = {
        Name = "Static Site Bucket"
        Environment = "Production" #ambiente que se está utilizando, poderia ser  Development
    }
}

#Cria um novo recuro para mudar a politica de acesso, para poder liberar o acessoa ao bucket
resource "aws_s3_bucket_public_access_block" "static_site_bucket"{
    # 1º pegamos o id do bucket que criamos no recurso anterior
    bucket = aws_s3_bucket.static_site_bucket.id

    # 2º Colocar as configurações que vão desbloquear o bucket, para liberar o acesso.
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

# Adicionando mais puliticas ao bucket
resource "aws_s3_bucket_ownership_controls" "static_site_bucket"{
    bucket = aws_s3_bucket.static_site_bucket.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "static_site_bucket" {
    depends_on = [ 
        aws_s3_bucket_public_access_block.static_site_bucket,
        aws_s3_bucket_ownership_controls.static_site_bucket
     ]  
     bucket = aws_s3_bucket.static_site_bucket.id
     acl = "public-read"
}

