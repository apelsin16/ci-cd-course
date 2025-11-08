# 🚀 Lesson 7: Професійний Деплой Django в AWS EKS за допомогою Terraform та Helm

Цей проєкт демонструє повний цикл **Infrastructure as Code (IaC)** та **GitOps** для розгортання контейнеризованого Django-застосунку в керованому кластері Kubernetes (AWS EKS).

---

## 1. ⚙️ Огляд та Технологічний Стек

* **Мета:** Створити кластер EKS, налаштувати ECR та розгорнути Django-застосунок, використовуючи Helm Chart.
* **Інфраструктура:** **AWS EKS**, **AWS ECR**, **AWS VPC**.
* **IaC:** **Terraform** (для EKS, ECR, IAM, S3 Backend).
* **Оркестрація:** **Helm Chart** (Deployment, Service LoadBalancer, HPA, ConfigMap).
* **Застосунок:** **Django** (працює на SQLite для цього розгортання).

---

## 2. ✅ Критерії Прийняття

| Критерій | Статус |
| :--- | :--- |
| **1. Кластер EKS** | Створений через Terraform і функціонує. |
| **2. ECR** | Створений і містить завантажений образ `django-app:v1.0.1`. |
| **3. Helm Chart** | Deployment, Service (LoadBalancer), HPA та ConfigMap успішно розгорнуті. |
| **4. ConfigMap** | Змінні середовища (`SECRET_KEY`, `ALLOWED_HOSTS`) успішно передано. |
| **5. Проєкт працює** | Застосунок доступний через LoadBalancer. |

---

## 3. 🚀 Інструкція з Розгортання

Виконайте ці кроки з кореневого каталогу проєкту (`lesson-5/`):

### 3.1. Створення Інфраструктури (EKS)

```bash
# Ініціалізація Terraform
terraform init

# Створення EKS кластера, ECR та IAM ролей
terraform apply --auto-approve

# Налаштування kubectl (використовуйте свій регіон)
aws eks update-kubeconfig --name django-k8s-cluster --region us-west-2

# 1. Побудова образу (використовує виправлений settings.py)
docker build -t django-app:v1.0.1 ./django

# 2. Завантаження образу до ECR (змініть Account ID)
docker tag django-app:v1.0.1 [803238624325.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:v1.0.1](https://803238624325.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:v1.0.1)
docker push [803238624325.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:v1.0.1](https://803238624325.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:v1.0.1)

# Оновлення та розгортання Helm Chart
helm upgrade --install django-app ./charts/django-app/

# Отримання зовнішньої адреси LoadBalancer
kubectl get svc django-app -w
# Використовуйте отриманий EXTERNAL-IP (DNS Name) для доступу.

# Видалення застосунку з Kubernetes
helm uninstall django-app

# Видалення всієї інфраструктури AWS
terraform destroy --auto-approve