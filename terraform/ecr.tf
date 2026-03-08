# Criação do Repositório para armazenar a imagem do nosso BackEnd.
resource "aws_ecr_repository" "backend_repo" {
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  # Escaneia para vulnerabildiades automaticamente no Push.
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.backend_repo.repository_url
  description = "URL do repositório ECR para o push da imagem"
}
