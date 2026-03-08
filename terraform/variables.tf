# Define as variáveis usadas no projeto, como região e nome do projeto.
variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

# Variável para o nome do projeto, usada como prefixo para os recursos, facilitando a identificação e organização.
variable "project_name" {
  description = "Nome base para os recursos do projeto"
  type        = string
  default     = "coinflip"
}
