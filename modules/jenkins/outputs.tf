/*
output "jenkins_admin_password" {
  value     = data.kubernetes_secret.jenkins_admin_password.data["jenkins-admin-password"]
  sensitive = true
}
*/
output "jenkins_url_instruction" {
  value = "Run: kubectl port-forward svc/jenkins -n jenkins 8080:8080 and open http://localhost:8080"
}