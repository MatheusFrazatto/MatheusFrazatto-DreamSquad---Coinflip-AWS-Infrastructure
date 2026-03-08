# Criação do Cluster ECS, Task Definition e Service para a aplicação backend.
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

# IAM Role para execução das tasks ECS, permitindo que o Fargate acesse os recursos necessários, como o ECR para puxar a imagem. Além de gerar logs.
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Definição da Task para a aplicação backend, especificando o container, a imagem do ECR e as portas expostas e os recusos de CPU e memória para a execução.
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "backend-container"
    image     = "${aws_ecr_repository.backend_repo.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
      protocol      = "tcp"
    }]
  }])
}

# Mantém o conteiner rodando e conectado ao ALB, garantindo que a aplicação esteja sempre disponível para receber requisições. 
resource "aws_ecs_service" "backend_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1 # Apenas 1 container ativo, mas caso precise de escalinamento, aumentar o número.

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true # Necessário para baixar a imagem do container sem usar o NAT Gateway, Visto que seu uso é caro.
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "backend-container"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.http] # Só sobe após o Load Balancer estar pronto para evitar erros de dependência.
}
