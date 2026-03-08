# 1. Imagem Base: versão 'slim' do Python para manter o container leve para uso no AWS ECR.
FROM python:3.9-slim

# 2. Diretório de Trabalho: Criação da pasta '/app' dentro do container. Além de entrar nela.
WORKDIR /app

# 3. Cache de Dependências: Copia apenas o requirements primeiro. Assim caso mude o código, o Docker pode usar o cache da instalação das dependências, acelerando a construção do container. 
COPY requirements.txt .

# 4. Instalação: Roda o pip para instalar o Flask e o Flask-Cors.
RUN pip install --no-cache-dir -r requirements.txt

# 5. Código Fonte: Copiamos o app.py para dentro do container.
COPY . .

# 6. Exposição da Porta: O container vai falar na porta 5000.
EXPOSE 5000

# 7. Comando de Inicialização: Comando que o container vai rodar quando ligar.
CMD ["python", "app.py"]