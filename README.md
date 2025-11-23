# Lesson 8-9: Повний CI/CD з Jenkins + Helm + Argo CD (GitOps)

**Студент:** apelsin16  
**Гілка:** `lesson-8-9`

## Схема CI/CD
git push → Jenkins → Kaniko → ECR (lesson-8-ecr) → git push у цей же репозиторій (оновлення charts/django-app/values.yaml) → Argo CD → автоматичний деплой у EKS
text## Як запустити інфраструктуру (Terraform)

```bash
# Клонуємо репозиторій і переходимо в гілку
git clone https://github.com/apelsin16/ci-cd-course.git
cd ci-cd-course
git checkout lesson-8-9

# Запускаємо всю інфраструктуру
terraform init
terraform apply -auto-approve
Після ~10 хвилин буде готово:

EKS кластер
Jenkins (з LoadBalancer)
Argo CD (з LoadBalancer)
ECR репозиторій lesson-8-ecr

Як перевірити Jenkins job

Отримай URL Jenkins:Bashkubectl get svc jenkins -n jenkins
# або
echo "http://$(kubectl get svc jenkins -n jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):8080"
Зайди в браузер:
Логін: admin
Пароль: admin123

Створи Pipeline job:
Name: django-ci-cd
Pipeline → Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://github.com/apelsin16/ci-cd-course.git
Branch: lesson-8-9
Script Path: Jenkinsfile

Натисни Build Now → дивись логи:
Kaniko збирає і пушить образ у ECR
Оновлюється charts/django-app/values.yaml (змінюється tag:)
Коміт пушиться назад у цей репозиторій


Як побачити результат в Argo CD

Отримай URL Argo CD:Bashkubectl get svc argocd-server -n argocd
Пароль admin:Bashkubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
Зайди в браузер → логін admin + пароль з команди вище
Ти побачиш Application django-app:
Status: Synced + Healthy
Після кожного запуску Jenkins → автоматично підтягується новий образ
URL додатка: подивись LoadBalancer сервісу django-app у namespace default


Додаткові команди
Bash# Переглянути логи Jenkins
kubectl logs -n jenkins -l app.kubernetes.io/component=jenkins-master

# Переглянути статус Argo CD Application
kubectl get application django-app -n argocd

# Очистити все (якщо треба)
terraform destroy -auto-approve
Готово!
Повний безручний CI/CD конвеєр з Jenkins + Kaniko + ECR + Helm + Argo CD (GitOps) працює автоматично.