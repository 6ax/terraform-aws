



_Используя Terraform:_
1. Требуется создать два инстанса в AWS один "сборочный" другой "продовый"
1. Собраем приложение в "сборочном" и катим в "продовый".
1. Собраем и катим приложение в Docker с помощью модулей Ansible для работы с Docker
1. Использовать для передачи "docker-image"  Amazon Elastic Container Registry.

**Реализация:**

1. Создаём пользователя с правами администратора в IAM.
1. Создаём репозитарий в Amazon Elastic Container Registry.
1. Сборка артефакта осуществляется при помощи Docker multi-stage.
1. Dockerfile для сборки берём из репозитария.

Создаём ssh-keys: `sh-keygen -t rsa -b 4096 -f ~/.ssh/aws_key`

Создаём: _~/.aws/credentials_

```
[default]
aws_access_key_id = my_key_id
aws_secret_access_key = my_access_key
```
_Разворачиваем инфраструктуру:_

```
terraform init
terraform plan
terraform apply -auto-approve
```

_Удаляем инфраструктуру:_
```
terraform destroy -auto-approv
```
