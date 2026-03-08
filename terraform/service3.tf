# Bucket onde os arquivos da rotina serão salvos.
resource "aws_s3_bucket" "daily_reports" {
  bucket        = "${var.project_name}-reports-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

# Transforma o "rotina.py" em um arquivo zip, para ser usado na criação da função Lambda.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/rotina.py"
  output_path = "${path.module}/rotina.zip"
}

# Define  que este serviço é uma lambda.
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Permissões de escrita de logs. Ele só pode escrever no Bucket de relatórios e criar logs no CloudWatch.
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:PutObject" # Permissão para criar o objeto.
        Resource = "${aws_s3_bucket.daily_reports.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Criação da função Lambda que executa o código Python.
resource "aws_lambda_function" "daily_routine" {
  function_name    = "${var.project_name}-daily-routine"
  role             = aws_iam_role.lambda_role.arn
  handler          = "rotina.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Injeta a dependência para o código Python via varável de ambiente.
  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.daily_reports.bucket
    }
  }
}

# Criação do EventBridge para disparar a função Lambda todos os dias as 10:00 BRT (13:00 UTC). Isso é um Cron Job.
resource "aws_cloudwatch_event_rule" "daily_10am" {
  name                = "${var.project_name}-10am-trigger"
  description         = "Dispara todos os dias as 10:00 BRT (13:00 UTC)"
  schedule_expression = "cron(0 13 * * ? *)" # Por utilizar o horário UTC, a função será disparada às 13:00 UTC, que corresponde às 10:00 BRT.
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.daily_10am.name
  target_id = "TriggerDailyLambda"
  arn       = aws_lambda_function.daily_routine.arn
}

# Conecta o EventBridge com a Lambda.
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.daily_routine.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_10am.arn
}

# Permissão para o EventBridge acordar a função Lambda.
output "reports_bucket_name" {
  value       = aws_s3_bucket.daily_reports.bucket
  description = "Nome do bucket onde a rotina diaria salvara os arquivos"
}
