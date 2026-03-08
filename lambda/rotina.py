import boto3
import os
from datetime import datetime, timedelta

s3 = boto3.client('s3')


def lambda_handler(event, context):
    """
    Função Lambda para criar um arquivo de texto no S3 diariamente com a data e hora atual. 
    É desparada pelo EventBridge todos os dias as 10:00 BRT (13:00 UTC).
    """
    print("Iniciando a rotina diária...")

    bucket_name = os.environ['DEST_BUCKET']

    # Calcula a data e hora atual em BRT (UTC-3)
    agora_brt = datetime.utcnow() - timedelta(hours=3)

    # Formata o nome do arquivo com a data e hora atual(requisito do desafio)
    nome_arquivo = agora_brt.strftime("%Y-%m-%d_%H-%M-%S.txt")

    conteudo = f"Este arquivo foi gerado automaticamente pela rotina do Servico 3.\nExecutado em: {agora_brt.strftime('%d/%m/%Y %H:%M:%S')}"

    try:
        print(f"Criando o arquivo: {nome_arquivo} no bucket {bucket_name}")

        # Cria o arquivo no S3 com o conteúdo especificado
        s3.put_object(
            Bucket=bucket_name,
            Key=nome_arquivo,
            Body=conteudo.encode('utf-8')
        )

        print("Rotina executada com sucesso!")
        return {
            'statusCode': 200,
            'body': f'Arquivo {nome_arquivo} criado com sucesso!'
        }

    except Exception as e:
        # Log de erro para facilitar o debug
        print(f"Erro ao criar o arquivo: {str(e)}")
        raise e
