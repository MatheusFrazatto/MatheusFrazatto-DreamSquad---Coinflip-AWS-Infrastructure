# Criação do ALB (Application Load Balancer) e Target Group para a aplicação ECS.
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false # ALB público para acesso externo.
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]                   #  Protegido pelo Security Group.
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id] # Exige 2 subnets públicas para alta disponibilidade.
}

# Target Group para a aplicação ECS.
resource "aws_lb_target_group" "ecs_tg" {
  name        = "${var.project_name}-tg"
  port        = 5000 # Porta onde a aplicação estará escutando.
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  # Configuração de Health Check para monitorar a saúde dos containers, verificando se a API está viva.
  health_check {
    path                = "/api/flip"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
  }
}

# Listener para o ALB, direcionando o tráfego HTTP para o Target Group da aplicação ECS.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "URL pública do Load Balancer para o acesso da API"
}
