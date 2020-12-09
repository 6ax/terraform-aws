sudo apt-get update \
&& sudo apt install -y docker.io

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt-get update -y",
  #     "sudo apt-get install -y docker.io awscli curl",
  #     "sudo curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
  #     "sudo chmod +x /usr/local/bin/docker-compose",
  #     "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
  #     "sudo aws ecr get-login-password --region ${local.region} | sudo docker login --username AWS --password-stdin ${local.ecr_url}"
  #   ]
  # }