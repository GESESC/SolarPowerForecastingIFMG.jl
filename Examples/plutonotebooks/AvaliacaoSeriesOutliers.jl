### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 2e16a029-4476-4146-a75a-98748f41f5cc
begin
	using Pkg
	Pkg.activate("/home/reginaldo/Insync/Trabalho/IFMG/IFMG_ARCOS/TCCs/TCCVitinho/SolarPowerForecastingIFMG.jl/Test/dev_env")
	#Pkg.update()
end

# ╔═╡ e767cc7a-9afc-4d32-8705-bc00b2beccd6
Pkg.add("CSV")

# ╔═╡ 50e894e2-97b1-489b-a629-be2720fb5b9c
using SolarPowerForecastingIFMG.RaspagemDeDadosINMET, SolarPowerForecastingIFMG.TruncagemDeDados

# ╔═╡ 2e5ea967-aec4-4563-b4f0-7b55ce91523e
begin
	using Plots
	gr()
end

# ╔═╡ 73d245d6-82c3-46e1-ad9c-8e231a02cb44
using MLJ,OutlierDetection

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
	dados = obter_dados(fonte_dados, ["FORMIGA"], 2019:2023)
	ajst_colnames!(dados);
	treat_data!(dados);0
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

# ╔═╡ a995ffa0-d0d2-4c57-b54d-44ad60dd924a


# ╔═╡ 8a46c032-afcb-4dd8-9792-112f432bb3cd
p = scatter(
	dados.serie[4].dataset[!, :DATE], 
	dados.serie[4].dataset[!, :ADSOLPW], 
	label="Coluna - $(String(:ADSOLPW))",
	markersize=3,
	markeralpha = 0.4,
	markerstrokewidth = 0.2,
    markerstrokealpha = 0.2,
	font=10
)

# ╔═╡ ef44d739-4ad3-4532-bc38-bff48f53caba
md"""
Modifique o número da série para valores abaixo de 10 (até 1) e acima de 10 (até 14) e verá que existem *outliers* absurdos antes da série 9 que se refere ao ano:
"""

# ╔═╡ 3fe774e9-662b-41d4-b1f4-e48dbfdbe592
println(dados.serie[4].ano)

# ╔═╡ 0d6eaf2b-5f63-4140-92e4-23354dd466c9
md"""
Efetivamente, esses *outlier* referem-se a erros de leitura ou registo nas datas especificadas.

O impacto da ausência desses pontos pode ser medido em algum experimento.

Recomendo que sejam feitas predições utilizando um recorte cronológico onde *outliers* não aparecem, e os resultados sejam comparados com os de outros experimentos que utilizem um recorte cronológico mais extenso que envolva um periódo com dados faltantes. 

O objetivo seria determinar:
*O que é melhor para a capacidade preditiva do modelo ? Usar um menor intervalo de para a predição sem dados faltantes, ou usar um intervalo de tempo consideravelmente maior mas com dados faltantes?*

Para a extração dos *outliers* do *dataset* é suficiente aplicar um crop dado por
$\bar{x} \pm 1.8\sigma$, usarei a biblioteca padrão *Statistics* para as funções média e desvio padrão.

Veja graficamente o comportamento da técnica.
"""

# ╔═╡ fefb36a5-5919-4709-a2b1-c8cda172e5c5
plts = Vector{Any}(undef, length(dados.serie))

# ╔═╡ 8d7429fd-13c5-4bf2-9c49-1b00f71fae37
begin
	n_elem = 1:length(dados.serie)
	for i in n_elem
		plts[i] = scatter(
			dados.serie[i].dataset[!, :DATE], 
			dados.serie[i].dataset[!, :ADSOLPW],
			xrotation = 20
		)
	end
	p1=plot(
		plts...,
		size=(1000,1000),
		layout=(3,3),
		legend=false,
		markersize=3,
		markeralpha = 0.4,
		markerstrokewidth = 0.2,
    	markerstrokealpha = 0.2,
		font=10
	)
	xlabel!(":DATE")
	ylabel!(":ADSOLPW")
end

# ╔═╡ c9e64e6d-3833-4c5b-a821-998675a2faac
md"Criando uma cópia dos dados."

# ╔═╡ a437ca1d-4a2b-49cf-90d4-c64061a40af3
cp_dados = deepcopy(dados);

# ╔═╡ fd71b0f7-e346-4960-acb9-7d139fc5d507
begin
	#concatenação das séries
	using DataFrames
	new_df = vcat([i.dataset for i in cp_dados.serie]...);
end

# ╔═╡ 7a3441c9-8f3a-4d99-8f35-c9a8bfe17bb4
begin
	using CSV
	CSV.write("DataForm2010To2023.csv", new_df)
end

# ╔═╡ ac9ab6d3-bb1e-4c1a-920a-e3996a20ac03
#=for i in 1:length(cp_dados.serie)
	cp_dados.serie[i].dataset[!,:ADSOLPW]= map(
		log, 
		cp_dados.serie[i].dataset[!,:ADSOLPW]
	)
end=#

# ╔═╡ 1276c9e9-e9e8-4f08-adb3-29c9dbc82d28
#using Statistics

# ╔═╡ dba9656f-ac9d-430e-9757-859686fe74b8
#=for i in n_elem
	#= 
		Definie uma função local e mutável a cada iteração que verifica se cada
		elemento da coluna :ADSOLPW pertence ao intervalo descrito acima.
	=#
	function ftcrp(x)
		med = mean(cp_dados.serie[i].dataset[!,:ADSOLPW])
		desv = std(cp_dados.serie[i].dataset[!,:ADSOLPW])
		if(med - 2. * desv) < x < (med + 2. * desv)
			true
		else
			false
		end
	end
	filter!(:ADSOLPW => ftcrp, cp_dados.serie[i].dataset)
end=

# ╔═╡ d10d6243-f387-4c82-86c8-1d5e70f75d91
begin
	for i in n_elem
		plts[i] = scatter(
			dados.serie[i].dataset[!, :DATE], 
			dados.serie[i].dataset[!, :ADSOLPW],
			xrotation = 20
		)
	end
	p2=plot(
		plts...,
		size=(1000,1000),
		layout=(3,2),
		legend=false,
		markersize=3,
		markeralpha = 0.4,
		markerstrokewidth = 0.2,
    	markerstrokealpha = 0.2,
		font=10
	)
	xlabel!(":DATE")
	ylabel!(":ADSOLPW")
end

# ╔═╡ 57df07be-89e9-4e62-948a-158f294d1a0c
md"""
## Empilhamento de dados para *forecasting* e persistência

Até este ponto não usamos recurso de persistência de dados para o armazenamento das séries. 

Uma função mais especializada nestas séries já está sendo implementada em um *branch* pessoal do pacote, no entanto para este trabalho faremos isso criando um arquivo `.csv` simples para armazenar todos as séries de forma contínua. Para a utilização 
do método ARIMA sasonal utilizaremos apenas as colunas `:DATE` e `:ADSOLPW`.
"""

# ╔═╡ d9a40c64-d88b-4214-b29e-aaa38ed0c1b0
typeof(new_df)

# ╔═╡ 2f2c234b-25b1-47d3-a931-06cf9c9d884c
md"Aqui tem-se em `new_df` os dados serializados, conforme pode ser visto no gráfico."

# ╔═╡ 0a3b911b-ef65-4b1e-83e2-3f4c8623a029
scatter(
	new_df[!,:DATE], 
	new_df[!, :ADSOLPW], 
	legend=false, 
	markersize=3,
	markeralpha = 0.6,
	markerstrokewidth = 0.2,
    markerstrokealpha = 0.2,
	font=10
)

# ╔═╡ e29cf5c1-370e-4bf7-b09b-817eeeb9e822
begin
	xlabel!("Data da Medida")
	ylabel!("Radiação Solar log[kJ/m²]")
end

# ╔═╡ 28965786-4180-4b1b-b7c3-66491165b7bb
train, test = split_df(new_df; frac = 0.5)

# ╔═╡ c3c776a0-510a-4695-aede-4ab597219362
md"Salvando os dados em formato `.csv`, se necessário adicione o pacote CSV."

# ╔═╡ Cell order:
# ╠═567996a6-b39b-11ed-19aa-271fe00ed366
# ╟─48d2a230-110c-4c78-99a8-a7cadbe3cad6
# ╠═2e16a029-4476-4146-a75a-98748f41f5cc
# ╠═50e894e2-97b1-489b-a629-be2720fb5b9c
# ╟─58fdcc2a-c3ce-4ac4-8f8c-17021d8ee1cb
# ╠═55a98bfb-c445-4c24-9dd9-11c24404c980
# ╟─88086dd5-d13a-4c0f-9748-e0651503ddd0
# ╠═37690607-9375-4792-86a5-fca71af27c84
# ╟─402726b0-4531-4d86-840d-d33ccb9a1a96
# ╠═1d3d4288-3c6c-429a-83d0-331d0ccda111
# ╟─feeba7f7-2208-4281-8dce-ce2ba5fd8830
# ╠═7095bdb2-b186-441b-97d4-6fd368d4900c
# ╠═2e5ea967-aec4-4563-b4f0-7b55ce91523e
# ╠═a995ffa0-d0d2-4c57-b54d-44ad60dd924a
# ╠═8a46c032-afcb-4dd8-9792-112f432bb3cd
# ╟─ef44d739-4ad3-4532-bc38-bff48f53caba
# ╠═3fe774e9-662b-41d4-b1f4-e48dbfdbe592
# ╠═0d6eaf2b-5f63-4140-92e4-23354dd466c9
# ╠═fefb36a5-5919-4709-a2b1-c8cda172e5c5
# ╠═8d7429fd-13c5-4bf2-9c49-1b00f71fae37
# ╟─c9e64e6d-3833-4c5b-a821-998675a2faac
# ╠═a437ca1d-4a2b-49cf-90d4-c64061a40af3
# ╠═ac9ab6d3-bb1e-4c1a-920a-e3996a20ac03
# ╠═1276c9e9-e9e8-4f08-adb3-29c9dbc82d28
# ╠═dba9656f-ac9d-430e-9757-859686fe74b8
# ╠═d10d6243-f387-4c82-86c8-1d5e70f75d91
# ╠═57df07be-89e9-4e62-948a-158f294d1a0c
# ╠═fd71b0f7-e346-4960-acb9-7d139fc5d507
# ╠═d9a40c64-d88b-4214-b29e-aaa38ed0c1b0
# ╠═2f2c234b-25b1-47d3-a931-06cf9c9d884c
# ╠═0a3b911b-ef65-4b1e-83e2-3f4c8623a029
# ╠═e29cf5c1-370e-4bf7-b09b-817eeeb9e822
# ╠═73d245d6-82c3-46e1-ad9c-8e231a02cb44
# ╠═28965786-4180-4b1b-b7c3-66491165b7bb
# ╠═c3c776a0-510a-4695-aede-4ab597219362
# ╠═e767cc7a-9afc-4d32-8705-bc00b2beccd6
# ╠═7a3441c9-8f3a-4d99-8f35-c9a8bfe17bb4
