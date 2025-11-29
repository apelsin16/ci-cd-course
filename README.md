# Фінальний проєкт: Повний CI/CD + Monitoring + Autoscaling на AWS

**Автор:** apelsin16  
**Гілка:** final-project

## Архітектура
- VPC + приватні/публічні підмережі
- EKS 1.31
- Aurora PostgreSQL 17.5
- ECR репозиторій
- Jenkins (Helm) + Kaniko + SSH-deploy
- Argo CD (GitOps)
- Prometheus + Grafana
- Django-додаток з HPA

## CI/CD
- Jenkinsfile в корені репозиторію
- Kaniko будує образ → пушить у ECR
- SSH-ключ → git push у цей же репозиторій
- Argo CD підхоплює зміну values.yaml → деплоїть

## Моніторинг
- kube-prometheus-stack (Grafana доступна через LoadBalancer)
- HPA на CPU

## Запуск
```bash
terraform init
terraform apply -auto-approve