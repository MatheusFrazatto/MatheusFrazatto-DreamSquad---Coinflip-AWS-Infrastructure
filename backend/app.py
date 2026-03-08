from flask import Flask, jsonify
from flask_cors import CORS
import random

app = Flask(__name__)
# Habilita CORS para permitir que o frontend acesse a API sem problemas de política de mesma origem.
CORS(app)


@app.route('/api/flip', methods=['GET'])
def flip_coin():
    """
    Rota principal do Serviço 2, que simula o lançamento de uma moeda. 
    Retorna um resultado aleatório de "cara" ou "coroa" em JSON.
    """
    resultado = random.choice(["cara", "coroa"])
    mensagem = f"Deu {resultado.capitalize()}!"

    return jsonify({
        "resultado": resultado,
        "mensagem": mensagem
    })


if __name__ == '__main__':
    """
    O host 0.0.0.0 permite que o aplicativo Flask seja acessível de fora do contêiner Docker, dentro da rede da AWS(VPC).
    """
    app.run(host='0.0.0.0', port=5000, debug=True)
