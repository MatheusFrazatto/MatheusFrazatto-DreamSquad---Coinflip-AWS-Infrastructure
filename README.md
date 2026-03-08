# 🪙 CoinFlip - Arquitetura Cloud AWS (Teste Técnico DreamSquad)

Bem-vindo ao repositório do projeto **CoinFlip**. Este projeto foi desenvolvido como resolução de desafio técnico, implementando uma arquitetura completa na AWS utilizando boas práticas de Infraestrutura como Código, Serverless e segurança de rede.

---

## 🏗️ Arquitetura do Projeto

O projeto está dividido em três serviços principais:

### Serviço 1 — FrontEnd  
Interface estática hospedada em um **S3 Bucket privado** e distribuída globalmente através do **Amazon CloudFront**.

### Serviço 2 — BackEnd  
API RESTful desenvolvida em **Python (Flask)** e conteinerizada com **Docker**.

**Fluxo:**
* A imagem Docker é armazenada no **Amazon ECR**.
* O container roda no **Amazon ECS (Fargate)**.
* O acesso ocorre através de um **Application Load Balancer (ALB)**.
* O serviço roda em uma **VPC privada** para maior segurança.

### Serviço 3 — Automação  
Rotina diária orientada a eventos:

* O **EventBridge** executa um agendamento (cron) todos os dias às 10:00.
* O evento dispara uma **AWS Lambda**.
* A Lambda gera um relatório em formato `.txt`.
* O arquivo gerado é salvo em um **Amazon S3**.

---

## 📊 Diagrama da Infraestrutura

<img width="882" height="622" alt="dreamsquad-coinflipdrawio" src="https://github.com/user-attachments/assets/300bf11d-c661-41fa-9d72-3a77f3f0878a" />

---

## 🛠️ Tecnologias Utilizadas

| Categoria                  | Tecnologia              |
| -------------------------- | ----------------------- |
| **Cloud Provider** | AWS                     |
| **Infraestrutura (IaC)** | Terraform               |
| **Containerização** | Docker                  |
| **Backend** | Python + Flask          |
| **Frontend** | HTML + CSS + JavaScript |
| **Automação** | AWS Lambda              |
| **Eventos** | EventBridge             |

---

## 📁 Estrutura do Repositório

```text
coinflip/
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── backend/
│   ├── app.py
│   └── Dockerfile
├── lambda/
│   └── daily_report.py
└── terraform/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

## 🚀 Como Executar

**Pré-requisitos:**
* AWS CLI configurado (`aws configure`)
* Terraform instalado
* Docker instalado

### 1. Provisionar a infraestrutura (Terraform)
```bash
cd terraform
terraform init
terraform apply
```

### 2. Deploy do BackEnd (Docker + ECR)
```bash
# Autenticar no ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ECR_URL>

cd ../backend

# Fazer o build da imagem
docker build -t coinflip-backend .

# Criar a tag
docker tag coinflip-backend:latest <ECR_URL>:latest

# Enviar para o repositório
docker push <ECR_URL>:latest
```

### 3. Deploy do FrontEnd (S3)
```bash
cd ../frontend
aws s3 sync . s3://<BUCKET_FRONTEND>
```

### 4. Testar a Automação (Lambda)
```bash
# Invocar a Lambda manualmente
aws lambda invoke --function-name coinflip-daily-routine response.json

# Verificar se o relatório foi criado no bucket
aws s3 ls s3://<BUCKET_REPORTS>
```

---

## 🧹 Limpeza

Para evitar cobranças indesejadas na AWS, destrua a infraestrutura quando terminar os testes:

```bash
cd terraform
terraform destroy
```

---
> *Projeto desenvolvido para o desafio técnico DreamSquad.*
