using HTTP
using Gumbo

function statusINMET()
    
    # Endereço constante do repositório de dados
    ENDERECO = "https://portal.inmet.gov.br/dadoshistoricos"

    resposta = HTTP.request("GET", ENDERECO)
    dados_anos = Gumbo.parsehtml(String(resposta.body))
    return dados_anos
    # Extrai as tags <a xxxx> xxxx </a>
    idx = 1
    list = []
    #for tag_a in dados_anos.root[2][4][1][1] # O método de indexação está frágil
    #    if idx%2 == 0
    #        push!(
    #            list, 
    #            split(tag_a[1][1].text)
    #        )
    #    end
    #    idx+=1
    #end
    #intervalo_de_dados = (prim_ano = list[1], ult_ano = list[end])

    #return intervalo_de_dados
end

resp = statusINMET()
