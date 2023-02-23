### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 2e16a029-4476-4146-a75a-98748f41f5cc
begin
	using Pkg
	Pkg.activate("/home/reginaldo/Insync/Trabalho/IFMG/IFMG_ARCOS/TCCs/TCCVitinho/SolarPowerForecastingIFMG.jl/Test/dev_env")
	Pkg.update()
end

# ╔═╡ 50e894e2-97b1-489b-a629-be2720fb5b9c
using SolarPowerForecastingIFMG.RaspagemDeDadosINMET, SolarPowerForecastingIFMG.TruncagemDeDados, DataFrames

# ╔═╡ 8c4403b4-71b0-4f4d-a05d-7188c6406c46
begin
	using Plots
	plotly()
end

# ╔═╡ 567996a6-b39b-11ed-19aa-271fe00ed366
md"""
# TCC - Victor Gonçalves
## Avaliando séries e *outliers*
Autor: Prof. Dr. Reginaldo Gonçalves Leão Junior
"""

# ╔═╡ 48d2a230-110c-4c78-99a8-a7cadbe3cad6
md"""
Um dos problemas com os quais precisamos lidar ao trabalhar com dados reais é a presença de *outliers*. O termo designa aqueles dados cujo o comportamento distoa severamente dos demais.

Os *datasets* extraídos do INMET possuem inúmeros destes pontos, principalmente quando são provenientes de estações meteorológicas automáticas, como é o caso da estação de Formiga.

Vamos inicar compondo um conjunto de *datasets* iniciado em 2010 e terminado em 2023 e então perscrutar visualmente a existência deste fenômeno.
"""

# ╔═╡ 58fdcc2a-c3ce-4ac4-8f8c-17021d8ee1cb
md"""
Devido ao grande conjunto de dados, este experimento pode demmandar alguns minutos de processamento computacional e *download*. 
"""

# ╔═╡ 55a98bfb-c445-4c24-9dd9-11c24404c980
begin
	fonte_dados = statusINMET();
	dados = obter_dados(fonte_dados, ["FORMIGA"], 2010:2023);
	ajst_colnames!(dados);
	treat_data!(dados);
end

# ╔═╡ 88086dd5-d13a-4c0f-9748-e0651503ddd0
md"""
O número de *datasets* presentes em `dados` pode ser inpecionado da seguinte forma:
"""

# ╔═╡ 37690607-9375-4792-86a5-fca71af27c84
println("Número de datasets na estrutura de captura de dados: $(length(dados.serie))")

# ╔═╡ 402726b0-4531-4d86-840d-d33ccb9a1a96
md"""
Uma boa inspeção visual em cada *dataset* pode ajudar a verificar se tudo se encontra bem. Aqui mostraremos uma saída de terminal para diminuir a demanda por memória e o tempo de processamento. 
"""

# ╔═╡ 1d3d4288-3c6c-429a-83d0-331d0ccda111
for ds in dados.serie
	println("Primeiros três elementos.")
	display(first(ds.dataset,3))
	println("Últimos três elementos.")
	display(last(ds.dataset,3))
end

# ╔═╡ feeba7f7-2208-4281-8dce-ce2ba5fd8830
md"""
Como estratégia de identificação dos *outliers* faremos uma plotagem interativa de cada uma das séries e então inspecionaremos o conjunto de gráficos de cada um dos anos.

Lembre-se que temos a seguinte lista de nomes das colunas:

`:ADRAIN :ADSOLPW :DTMAX_C :DTMIN_C :DATE`

Em todos os gráficos utilizaremos `:DATE` como eixo horizontal.

Pode ser necessária a instalação do *backend* para gráficos interativos.
"""

# ╔═╡ 7095bdb2-b186-441b-97d4-6fd368d4900c
#begin
#	Pkg.add("PlotlyBase")
#	Pkg.add("PlotlyKaleido")
#end

# ╔═╡ 8a46c032-afcb-4dd8-9792-112f432bb3cd
p = scatter(
	dados.serie[10].dataset[!, :DATE], 
	dados.serie[10].dataset[!, :ADRAIN], 
	label="Coluna - $(String(:ADRAIN))",
	ms = 1.8
)

# ╔═╡ ef44d739-4ad3-4532-bc38-bff48f53caba
md"""
Modifique o número da série para valores abaixo de 10 (até 1) e acima de 10 (até 14) e verá que existem *outliers* absurdos antes da série 9 que se refere a:
"""

# ╔═╡ 3fe774e9-662b-41d4-b1f4-e48dbfdbe592
println(dados.serie[9].ano)

# ╔═╡ 0d6eaf2b-5f63-4140-92e4-23354dd466c9
md"""
Desta forma você verificará qual melhor intervalo temporal de trabalho para a estação de Formiga.
"""

# ╔═╡ Cell order:
# ╟─567996a6-b39b-11ed-19aa-271fe00ed366
# ╟─48d2a230-110c-4c78-99a8-a7cadbe3cad6
# ╠═2e16a029-4476-4146-a75a-98748f41f5cc
# ╠═50e894e2-97b1-489b-a629-be2720fb5b9c
# ╟─58fdcc2a-c3ce-4ac4-8f8c-17021d8ee1cb
# ╠═55a98bfb-c445-4c24-9dd9-11c24404c980
# ╠═88086dd5-d13a-4c0f-9748-e0651503ddd0
# ╠═37690607-9375-4792-86a5-fca71af27c84
# ╠═402726b0-4531-4d86-840d-d33ccb9a1a96
# ╠═1d3d4288-3c6c-429a-83d0-331d0ccda111
# ╟─feeba7f7-2208-4281-8dce-ce2ba5fd8830
# ╠═7095bdb2-b186-441b-97d4-6fd368d4900c
# ╠═8c4403b4-71b0-4f4d-a05d-7188c6406c46
# ╠═8a46c032-afcb-4dd8-9792-112f432bb3cd
# ╠═ef44d739-4ad3-4532-bc38-bff48f53caba
# ╠═3fe774e9-662b-41d4-b1f4-e48dbfdbe592
# ╠═0d6eaf2b-5f63-4140-92e4-23354dd466c9
