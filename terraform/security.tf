# Security Group do Load Balancer.
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Permite trafego HTTP de entrada no Load Balancer"
  vpc_id      = aws_vpc.main.id

  #Qualquer usuário na internet pode acessar o ALB via HTTP(HTTPS não funcionará) na porta 80.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite que o ALB envie tráfego para qualquer destino(usado para conversar com o ECS).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group do Backend.
resource "aws_security_group" "ecs_sg" {
  name        = "${var.project_name}-ecs-sg"
  description = "Permite trafego apenas do Load Balancer"
  vpc_id      = aws_vpc.main.id

  # Não aceita tráfego da internet, apenas conexões na porta 5000 vindas do SG do ALB.
  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
