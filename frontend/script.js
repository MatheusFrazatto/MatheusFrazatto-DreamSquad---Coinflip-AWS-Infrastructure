document.getElementById('flipButton').addEventListener('click', async () => {
    const resultadoTexto = document.getElementById('resultadoTexto');
    const resultadoBox = document.getElementById('resultadoBox');

    resultadoBox.classList.remove('hidden');

    try {
        /*Faz a requisição para a API do Serviço 2 */
        const response = await fetch('http://coinflip-alb-388181438.us-east-1.elb.amazonaws.com/api/flip');

        if (!response.ok) {
            throw new Error('Erro na comunicação com a API');
        }

        const data = await response.json();
        resultadoTexto.innerText = data.mensagem;

    } catch (error) {
        /*Trata erros na requisição */
        console.error("Erro:", error);
        resultadoTexto.innerText = "Erro ao conectar com o servidor.";
    }
});