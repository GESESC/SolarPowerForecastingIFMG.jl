### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ b5760ba6-398e-48fe-aee8-e6440a2711a0
begin
	using Pkg
	Pkg.activate("/home/reginaldo/Insync/Trabalho/IFMG/IFMG_ARCOS/TCCs/TCCVitinho/SolarPowerForecastingIFMG.jl/Test/dev_env")
	Pkg.update()
end

# ╔═╡ 74dc1203-63c8-4c2a-9718-ccb74f0d3f5e
using SolarPowerForecastingIFMG.RaspagemDeDadosINMET, SolarPowerForecastingIFMG.TruncagemDeDados, DataFrames, PlutoUI

# ╔═╡ 4dfb5000-ad56-11ed-2793-07029cb1fd07
md"""
# TCC - Victor Gonçalves
## Instruções de obtenção de dados
Autor: Prof. Dr. Reginaldo Gonçalves Leão Junior


### Verificação do status INMET

Consiste na chamada à função `statusINMET()` que verifica a disponibilidade de séries anuais climatológicas no recurso `/dadoshistoricos` do portal, exibe um compilado deste estatus no terminal e retorna um dicionário com a estrutura:

```
Dict{Int16, String} with n entries:
  "20XX" => "https://portal.inmet.gov.br/uploads/dadoshistoricos/20XX.zip"
```

no qual as chaves são os anos disponíveis na base no formato de um inteiro de 32 bits e os valores uma String contendo o link para download do zip file das séries para o respectivo ano.
"""

# ╔═╡ 8ce37dc2-a9f2-4d28-9803-1cf641017f18
md"""
Antes de qualquer verificação, deve-se fazer a instalação do pacote em desenvolvimento, ou verificação por atualizações.
Sendo o primeiro uso do pacote em uma determinada instalação deve-se executar as instruções do comentário `i)`, nas demais, atualizações devem ser checadas por meio das instruções do comentário `ii)`. A instrução `using Pkg` é apenas uma chamada ao módulo `Pkg` responsável pela gerência dos pacotes.
"""

# ╔═╡ 43180b6c-96cd-4575-ae31-8a0a30b161ee
# i) Na primeira execução do pacote
#begin
#	using Pkg
#	Pkg.add(url="https://github.com/GESESC/SolarPowerForecastingIFMG.jl")
#	Pkg.add("PlutoUI")
#end

# ╔═╡ 902b43f5-8803-409f-b1bb-3d7211c4e55b
# ii) A cada nova adição de funcionalidade
#begin
#	using Pkg
#   Pkg.update("SolarPowerForecastingIFMG")
#end

# ╔═╡ 630a6ab9-c936-425d-8d62-2cd990f226b0
md"""
Opcionalmente o repositório [SolarPowerForecastingIFMG.jl](https://github.com/GESESC/SolarPowerForecastingIFMG.jl) possui no diretório `Test` o subdiretório `dev_env` onde as configurações para a execução já estão pré-configuradas nos arquivos `Project.toml` e `Manifest.toml` para saber mais sobre essas configurações consulto a seção [*Project environments*](https://docs.julialang.org/en/v1/manual/code-loading/#Project-environments) na documentação da linguagem.


Usarei essa estratégia `iii)` neste notebook.
"""

# ╔═╡ 37ca5666-1359-406c-9012-868db00b167f
md"""
Após a instalação, ativação do ambiente ou atualização, o pacote deve ser carregado no *kernel* em execução, em seguida a verificação do status no INMET pode ser imediatamente realizada.
"""

# ╔═╡ 4b0c3a7b-5649-4c13-bfe7-e713d3b4d1df
md"""
O processo de raspagem dos dados no INMET se dá primeiramente pela obtenção de um espelho do site de dados e extração das informações para download dos dados. Tudo isso é feito de forma automatizada por meio do método `statusINMET()`.
"""

# ╔═╡ 4b5131e6-1226-4eb8-9407-f4f1d9b85630
fonte_dados = statusINMET();

# ╔═╡ 097341e9-759a-46a2-a823-9ac618af158e
md"""
Após a execução a variável `fonte_dados` é um dicionário que contém os links para a obtenção das tabelas CSV de cada ano.
"""

# ╔═╡ 06367819-0e34-4d0c-b838-ca1394fd83fc
@show fonte_dados[2000];

# ╔═╡ b46819c9-7e21-46bb-a974-f199fcf45d39
@show fonte_dados[2010];

# ╔═╡ 15063db5-8983-4614-b699-e94974ee4def
@show fonte_dados[2022];

# ╔═╡ 4c6568e7-a80b-4ddd-b7e8-4181fe486b4a
md"""
### Raspagem de Dados
A extração de dados em si se dá por meio da função `obter_dados` cuja documentação pode ser consultada na ferramenta *Live Docs* (verifique o botão na parte inferior direita deste notbook).

No exemplo abaixo utilizamos a função `obter_dados` para a `fonte_dados` requerendo estes para a cidade de Formiga e o ano de 2010.
Note como esses parâmetros foram passados na forma de vetores, de forma tal que, mais de uma cidade, ou mesmo, mais que um ano de estudo podem ser selcionados.
"""

# ╔═╡ 9940d90a-7a9d-467f-8062-ccf04a066029
dados = obter_dados(fonte_dados, ["FORMIGA"], [2010]);

# ╔═╡ f5bfad1b-d8d0-47a8-ac95-ce84ef05ba98
dados

# ╔═╡ f4d70f3a-dad9-427b-bf40-74058770aa65
md"""
Quando `dados` é exibido, se vê um problema de codificação no nome das colunas como por exemplo `PRECIPITA\xc7\xc3O` na terceira coluna, isto é uma falha de codificação na fonte dos dados. 
A lista de nomes das colunas pode ser inspecioanda utilizando-se a função name no objeto do tipo `dataset` pertencente à `mutable struct EstruturaDeCaptura`.
"""

# ╔═╡ 619d2fef-e1d7-43d6-aa77-17766c4fed28
names(dados.serie[1].dataset)

# ╔═╡ f18c185f-c27d-4186-80d8-079b0480b9bc
md"""
A estrtura de captura de dados no submódulo `RaspagemDeDadosINMET.jl` é organizada na forma:
```Julia
mutable struct EstruturaDeCaptura
    cidade::Union{String, Nothing}
    ano::Union{Int, String, Nothing}
    dataset::Union{DataFrame, Nothing}
end

mutable struct SerieCidades 
    serie::AbstractVector{EstruturaDeCaptura}
end
```
Na qual a `mutable struct SerieCidades` é utilizada para armazenar os dados das múltiplas cidades desejadas para o estudo, e a `mutable struct EstruturaDeCaptura` cotém o nome de cada cidade, e o nome de cada ano de estudo, além dos dados proprieamente ditos na forma de `DataFrame` do tipo `DataFrames.jl`.

Em nosso caso, as seguintes colunas precisam de ajuste de codificação de caractere:

3. `PRECIPITA\xc7\xc3O TOTAL, HOR\xc1RIO (mm)` para `PRECIPITACAO TOTAL, HORARIA (mm)`;
5. `PPRESS\xc3O ATMOSFERICA MAX.NA HORA ANT. (AUT) (mB)` para `PRESSAO ATMOSFERICA MAX.NA HORA ANT.(AUT) (mB)`;
6. `PPRESS\xc3O ATMOSFERICA MIN.NA HORA ANT. (AUT) (mB)` para `PRESSAO ATMOSFERICA MIN.NA HORA ANT.(AUT) (mB)`;
7. `RADIACAO GLOBAL (KJ/m\xb2)` para `RADIACAO GLOBAL (KJ/m²)`;
8. `TEMPERATURA DO AR - BULBO SECO, HORARIA (\xb0C)` para `TEMPERATURA DO AR - BULBO SECO, HORARIA (°C)`;
9. `TEMPERATURA DO PONTO DE ORVALHO (\xb0C)` para `TEMPERATURA DO PONTO DE ORVALHO (°C)`;
10. `TEMPERATURA M\xc1XIMA NA HORA ANT. (AUT) (\xb0C)` para `TEMPERATURA MAXIMA NA HORA ANT.(AUT) (°C)`;
11. `TEMPERATURA M\xcdNIMA NA HORA ANT. (AUT) (\xb0C)` para `TEMPERATURA MINIMA NA HORA ANT.(AUT) (°C)`;
12. `TEMPERATURA ORVALHO MAX. NA HORA ANT. (AUT) (\xb0C)` para `TEMPERATURA ORVALHO MAX. NA HORA ANT. (AUT) (°C)`;
13. `TEMPERATURA ORVALHO MIN. NA HORA ANT. (AUT) (\xb0C)` para `TEMPERATURA ORVALHO MIN. NA HORA ANT. (AUT) (°C)`;
18. `VENTO, DIRE\xc7\xc3O HORARIA (gr) (\xb0 (gr))` para `VENTO, DIRECAO HORARIA (gr) (°(gr))`;

Na primeira versão do pacote esse ajuste era realizado de forma manual, na versão atual foi implementado o método mutante `ajst_colnames!()` que realiza o processo de correção de codificação de maneira automatizada.
"""

# ╔═╡ 65629dd5-485a-452a-9f00-88bfc78d029a
md"""
No código abaixo usa-se o método de correção e em seguida são exibidos os novos nomes das *features* presentes nos dados. 
"""

# ╔═╡ c9242554-2d71-4291-988f-3ccbfdf5d192
begin
	ajst_colnames!(dados);
	names(dados.serie[1].dataset)
end

# ╔═╡ Cell order:
# ╟─4dfb5000-ad56-11ed-2793-07029cb1fd07
# ╟─8ce37dc2-a9f2-4d28-9803-1cf641017f18
# ╠═43180b6c-96cd-4575-ae31-8a0a30b161ee
# ╠═902b43f5-8803-409f-b1bb-3d7211c4e55b
# ╟─630a6ab9-c936-425d-8d62-2cd990f226b0
# ╠═b5760ba6-398e-48fe-aee8-e6440a2711a0
# ╟─37ca5666-1359-406c-9012-868db00b167f
# ╠═74dc1203-63c8-4c2a-9718-ccb74f0d3f5e
# ╟─4b0c3a7b-5649-4c13-bfe7-e713d3b4d1df
# ╠═4b5131e6-1226-4eb8-9407-f4f1d9b85630
# ╟─097341e9-759a-46a2-a823-9ac618af158e
# ╠═06367819-0e34-4d0c-b838-ca1394fd83fc
# ╠═b46819c9-7e21-46bb-a974-f199fcf45d39
# ╠═15063db5-8983-4614-b699-e94974ee4def
# ╟─4c6568e7-a80b-4ddd-b7e8-4181fe486b4a
# ╠═9940d90a-7a9d-467f-8062-ccf04a066029
# ╠═f5bfad1b-d8d0-47a8-ac95-ce84ef05ba98
# ╠═f4d70f3a-dad9-427b-bf40-74058770aa65
# ╠═619d2fef-e1d7-43d6-aa77-17766c4fed28
# ╟─f18c185f-c27d-4186-80d8-079b0480b9bc
# ╟─65629dd5-485a-452a-9f00-88bfc78d029a
# ╠═c9242554-2d71-4291-988f-3ccbfdf5d192
