using HTTP
using Gumbo

function statusINMET()
    
    # Endereço constante do repositório de dados
    ENDERECO = "https://portal.inmet.gov.br/dadoshistoricos"

    resposta = HTTP.request("GET", ENDERECO)
    dados_anos = Gumbo.parsehtml(String(resposta.body))

    # Extrai as tags <a xxxx> xxxx </a> 
    dados_anos = dados_anos.root[2][4][1][1][2:2:end]
end

resp = statusINMET()