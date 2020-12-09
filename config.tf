
provider "aws" {
  region = local.region
}

resource "aws_key_pair" "builder" {
  key_name   = "aws_key_builder"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDvUx6FSY4+ms7b72f48XjMaMes0FN64qT5njQuz+XRsCyDAKWHBvlOjNFAeauoIY3/06Uk6RSr06DPOMOTGZeJXaCqd19cTWyRm0xaLVmEKLFYmlF62dQyoqCn1biJ6WhQdclTf1clKcFlnUj3hEBvXTOPQ/VvYsiqcbOwdu9pyo51BnXsCRmeDfvEV+y9TupXFZ9GtmrzWZHIUENiG8PgSQUUmO2ZM2dlxcfx/soXArGcDerAMtfhI1L/E6WCSFj+11x29WwTfn5myPlMGHp02fkWg0qDqrzcwxaqUwu9Z98KImnuJOwWxbJwQwr2nOUrRO5cWxJZYzhZQcHVw/B5udmWbJyhnn4Ltxwfr2V2Ev8c3IK8fmhoPZC5qfwoL/cAAqpWRVfQtxi6zOvD88dYdkIWAXWHgGRlVCWPC17QzHwKKmFbpEyWPP041Vjg73Wur7UeE3A8wXdh70b50lumkYC6fBnoedIim1qHOC5IiGjTpHZjE2Z4nocgIoAVXDP6BzaUVzycTSef/ta7z6LeMYPEVM3jkCYfk17ByO0ITSEInNvE6F+gy+5vMv3ONWcogqzl8+WJ1246QW5WR4O69Eqz3x1nxvSXlmNSUeniHzvuvrUQ3HSOAKLroIbyjDix5I8pH0iM5wcY7a0BLWecc+jYuoq4/EoUcPal3FAQqw== root@for-test"
}

resource "aws_security_group" "builder" {
  name        = "builder_security_group"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "builder" {
  ami           = local.ami
  key_name      = aws_key_pair.builder.id
  instance_type = local.instance_type
  vpc_security_group_ids = [aws_security_group.builder.id]
#   user_data = templatefile("builder.sh.tpl", {
#       REPO_URL = aws_ecr_repository.app42paas.repository_url,
#       SOFT_NAME = local.soft_name,
#       REGION = local.region
#       })
  tags = {
        Name = "builder"
  }
  connection {
        type     = "ssh"
        user     = "ubuntu"
        private_key = file("~/.ssh/aws_key")
        host     = self.public_ip
    }
  provisioner "file" {
  source      = "~/.aws"
  destination = "~/"
  }

    provisioner "local-exec" {
    command = "sleep 10"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt install -y docker.io awscli git",
      "git clone http://gitlab.6ax.su/6ax/compose-App42PaaS-Java-MySQL-Sample.git /tmp/${local.soft_name}",
      "cd /tmp/${local.soft_name}",
      "sudo docker build . -t ${aws_ecr_repository.app42paas.repository_url}",
      "sudo aws ecr get-login-password --region ${local.region} | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.app42paas.repository_url}",
      "sudo docker push ${aws_ecr_repository.app42paas.repository_url}"
    ]
  }
}

resource "aws_ecr_repository" "app42paas" {
  name                 = "app42paas"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_key_pair" "prod" {
  key_name   = "aws_key_prod"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDvUx6FSY4+ms7b72f48XjMaMes0FN64qT5njQuz+XRsCyDAKWHBvlOjNFAeauoIY3/06Uk6RSr06DPOMOTGZeJXaCqd19cTWyRm0xaLVmEKLFYmlF62dQyoqCn1biJ6WhQdclTf1clKcFlnUj3hEBvXTOPQ/VvYsiqcbOwdu9pyo51BnXsCRmeDfvEV+y9TupXFZ9GtmrzWZHIUENiG8PgSQUUmO2ZM2dlxcfx/soXArGcDerAMtfhI1L/E6WCSFj+11x29WwTfn5myPlMGHp02fkWg0qDqrzcwxaqUwu9Z98KImnuJOwWxbJwQwr2nOUrRO5cWxJZYzhZQcHVw/B5udmWbJyhnn4Ltxwfr2V2Ev8c3IK8fmhoPZC5qfwoL/cAAqpWRVfQtxi6zOvD88dYdkIWAXWHgGRlVCWPC17QzHwKKmFbpEyWPP041Vjg73Wur7UeE3A8wXdh70b50lumkYC6fBnoedIim1qHOC5IiGjTpHZjE2Z4nocgIoAVXDP6BzaUVzycTSef/ta7z6LeMYPEVM3jkCYfk17ByO0ITSEInNvE6F+gy+5vMv3ONWcogqzl8+WJ1246QW5WR4O69Eqz3x1nxvSXlmNSUeniHzvuvrUQ3HSOAKLroIbyjDix5I8pH0iM5wcY7a0BLWecc+jYuoq4/EoUcPal3FAQqw== root@for-test"
}

resource "aws_security_group" "prod" {
  name        = "prod_security_group"
  description = "Allow SSH inbound traffic"

  dynamic "ingress" {
    for_each = [22, 8080]
    content{
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "prod" {
  ami           = local.ami
  key_name      = aws_key_pair.prod.id
  instance_type = local.instance_type
  vpc_security_group_ids = [aws_security_group.prod.id]

  tags = {
        Name = "prod"
  }
  connection {
        type     = "ssh"
        user     = "ubuntu"
        private_key = file("~/.ssh/aws_key")
        host     = self.public_ip
    }
  provisioner "file" {
  source      = "~/.aws"
  destination = "~/"
  }
  provisioner "local-exec" {
    command = "sleep 10"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io awscli curl",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
      "sudo aws ecr get-login-password --region ${local.region} | sudo docker login --username AWS --password-stdin ${local.ecr_url}",
      "sudo curl https://gitlab.6ax.su/6ax/compose-App42PaaS-Java-MySQL-Sample/-/raw/master/docker-compose-only-start.yml --output docker-compose.yml",
      "sudo docker-compose up -d"
    ]
  }
   depends_on = [
    aws_instance.builder
  ]
}
