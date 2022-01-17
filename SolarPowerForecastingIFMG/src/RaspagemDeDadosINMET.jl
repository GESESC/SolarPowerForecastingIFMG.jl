using HTTP 
using Gumbo
using Downloads
using ZipFile
using CSV 
using DataFrames

struct EstruturaDeCaptura
    cidade::Union{String, Nothing}
    ano::Union{Int, String, Nothing}
    dataset::Union{DataFrame, Nothing}
end
struct SerieCidades 
    serie::AbstractVector{EstruturaDeCaptura}
end

"""
Realiza uma requisição http ao portal do inmet no recurso /dadoshistoricos, 
realiza um parse da resposta html via Gumbo e em seguida extrai os links e 
textos que contêm as tabelas CSVs de cada série anual disponibilizada no recurso
retornando um dicionário com a estrutura:

Dict{Int16, String} with n entries:
  "20XX" => "https://portal.inmet.gov.br/uploads/dadoshistoricos/20XX.zip"

onde a chave é uma string contendo o ano de consulta, e o valor uma segunda 
string com o link do zip file no servidor do INMET.
"""
function statusINMET()
    
    # Endereço constante do repositório de dados
    ENDERECO_INMET = "https://portal.inmet.gov.br/dadoshistoricos"

    resposta = HTTP.request("GET", ENDERECO_INMET)
    dados_anos = Gumbo.parsehtml(String(resposta.body))
    idx = 2
    series = Dict{Int16, String}()
    #series = {Dict{String, String}}[]
    while true
        try
            #=
             Realizar um benckmark para verificar desempenho
             Abordagem 1
            =# 
            series[
                parse(
                    Int32,
                    split(
                        dados_anos.root[2][4][1][1][idx][1][1].text
                    )[2]
                )
            ] = attrs(
                dados_anos.root[2][4][1][1][idx][1]
            )["href"]
            idx+=2

            #= 
            Abordagem 2 - outros ajustes são necessários para uso desse
            método
            Pares links e texto
            link = "link" => attrs(
                dados_anos.root[2][4][1][1][idx][1]
            )["href"]
            texto = "ano" => split(
                dados_anos.root[2][4][1][1][idx][1][1].text
            )[2]
            push!(list, Dict(link, texto))
            idx+=2
            =#
            
        catch
            break
        end
    end
    chaves_ord = sort(collect(keys(series)))
    prim, ulti = chaves_ord[1], chaves_ord[end]
    printstyled("Estrato de dados INMET\n"; bold=true)
    printstyled("Primeiro ano disponível\t->\t")
    printstyled("$prim\n"; bold=true, color=:light_blue)
    printstyled("Último ano disponível\t->\t")
    printstyled("$ulti\n"; bold=true, color=:light_blue)
    return series
end

"""
Recebe um dicionário com chaves do tipo Int16, contendo o ano de uma determinada 
série histórica do INMET e uma String com o link de download da série no 
servidor dois vetores, uma lista das cidades a serem estudadas e outra com a 
lista dos anos a serem estudados ou um UnitRang com este intervalo de estudo.
"""
function obter_dados(
    fonte_dados::Dict{Int16, String}, 
    cidades::Vector{String}, 
    intervtemp::Vector{Int}
)
    try
        # Aramazenamento na memória - scopo da função
        dados_cidades = SerieCidades(
            fill(
                EstruturaDeCaptura(
                    nothing, 
                    nothing, 
                    nothing
                ), length(intervtemp) * length(cidades)
            )
        )

        contador = 1
        for ano in intervtemp

            #= Manutenção de diretórios, caso seja interessante criar subpastas
                diretorio = string("Dir", ano)
                mkdir(diretorio)
                cd(diretorio)
            =#

            # Manipulação dos arquivos
            Dowloads.dowload(fonte_dados[ano])
            arquivo_zip = readdir()[1]
            zip_lido = ZipFile.Reader(arquivo_zip)                        
            for cid in cidades
                for arq in zip_lido.files
                    if occursin(
                        Regex("$(lowercase(cid))"), 
                        lowercase(arq.name)
                    )
                        #= 
                        Os DataFrames estão sendo armazenados completamente na
                        memória, no futuro conseguir uma forma de excluir as 
                        séries que não são de interesse para o modelo. 
                        =#
                        dados_cidades[contador].cidade = cid
                        dados_cidades[contador].ano = ano
                        dados_cidades[contador].dataset = CSV.read(
                            arq, 
                            DataFrame
                        )
                        contador+=1
                    end
                end
            end
            close(zip_lido)
        end
        rm("*.zip")
        return dados_cidades
    catch
        error("Parâmetros inválidos! ")
         
    end
end

function obter_dados(
    fonte_dados::Dict{Int16, String},
    cidades::Vector{String}, 
    intervtemp::UnitRange
)
    try
        # Aramazenamento na memória - scopo da função
        dados_cidades = SerieCidades(
            fill(
                EstruturaDeCaptura(
                    nothing, 
                    nothing, 
                    nothing
                ), length(intervtemp) * length(cidades)
            )
        )

        contador = 1
        for ano in intervtemp

            #= Manutenção de diretórios, caso seja interessante criar subpastas
                diretorio = string("Dir", ano)
                mkdir(diretorio)
                cd(diretorio)
            =#

            # Manipulação dos arquivos
            Dowloads.dowload(fonte_dados[ano])
            arquivo_zip = readdir()[1]
            zip_lido = ZipFile.Reader(arquivo_zip)                        
            for cid in cidades
                for arq in zip_lido.files
                    if occursin(
                        Regex("$(lowercase(cid))"), 
                        lowercase(arq.name)
                    )
                        #= 
                        Os DataFrames estão sendo armazenados completamente na
                        memória, no futuro conseguir uma forma de excluir as 
                        séries que não são de interesse para o modelo. 
                        =#
                        dados_cidades[contador].cidade = cid
                        dados_cidades[contador].ano = ano
                        dados_cidades[contador].dataset = CSV.read(
                            arq, 
                            DataFrame
                        )
                        println(dados_cidades[contador])
                        contador+=1
                    end
                end
            end
            close(zip_lido)
        end
        rm("*.zip")
        return dados_cidades
    catch
        error("Parâmetros inválidos! ")
        
    end
end

