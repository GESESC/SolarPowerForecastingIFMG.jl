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

# ╔═╡ 50e894e2-97b1-489b-a629-be2720fb5b9c
using SolarPowerForecastingIFMG.RaspagemDeDadosINMET, SolarPowerForecastingIFMG.TruncagemDeDados

# ╔═╡ 2e5ea967-aec4-4563-b4f0-7b55ce91523e
begin
	using Plots
	gr()
end

# ╔═╡ 2256deca-9b41-4390-91ce-f0eebfbf92d3
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
	dados = obter_dados(fonte_dados, ["FORMIGA"], 2010:2023)
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
Uma boa inspeção visual em cada *dataset* pode ajudar a verificar se tudo se encontra bem. Aqui mostraremos apenas uma saída de terminal para diminuir a demanda por memória e o tempo de processamento. 
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
Como estratégia inicial de identificação dos *outliers* faremos uma plotagem de cada uma das séries e então inspecionaremos o conjunto de gráficos de cada um dos anos.

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

# ╔═╡ fa07a25f-25b3-4bdd-9b0a-00b279e09391
plts = Vector{Any}(undef, length(dados.serie));

# ╔═╡ 8a46c032-afcb-4dd8-9792-112f432bb3cd
#:DTMAX_C :DTMIN_C :DATE
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
		layout=(4,4),
		legend=false,
		markersize=3,
		markeralpha = 0.4,
		markerstrokewidth = 0.2,
    	markerstrokealpha = 0.2,
		font=10
	)
	xlabel!(":DATE")
	ylabel!(":ADSOLPW (kJ/m²)")
end

# ╔═╡ 3478bc11-1152-4e58-b43c-a89e69c9e1bc
begin
	for i in n_elem
		plts[i] = scatter(
			dados.serie[i].dataset[!, :DATE], 
			dados.serie[i].dataset[!, :ADRAIN],
			xrotation = 20
		)
	end
	p2=plot(
		plts...,
		size=(1000,1000),
		layout=(4,4),
		legend=false,
		markersize=3,
		markeralpha = 0.4,
		markerstrokewidth = 0.2,
    	markerstrokealpha = 0.2,
		font=10
	)
	xlabel!(":DATE")
	ylabel!(":ADRAIN (mm)")
end

# ╔═╡ 4eb197bc-6a32-48a5-be6a-e1b954451317
#:DTMIN_C :DATE
begin
	for i in n_elem
		plts[i] = scatter(
			dados.serie[i].dataset[!, :DATE], 
			dados.serie[i].dataset[!, :DTMAX_C],
			xrotation = 20
		)
	end
	p3=plot(
		plts...,
		size=(1000,1000),
		layout=(4,4),
		legend=false,
		markersize=3,
		markeralpha = 0.4,
		markerstrokewidth = 0.2,
    	markerstrokealpha = 0.2,
		font=10
	)
	xlabel!(":DATE")
	ylabel!(":DTMAX_C (°C)")
end

# ╔═╡ 7e84fdf7-f87e-456a-b994-424dac495344
#:DTMIN_C :DATE
begin
	for i in n_elem
		plts[i] = scatter(
			dados.serie[i].dataset[!, :DATE], 
			dados.serie[i].dataset[!, :DTMIN_C],
			xrotation = 20
		)
	end
	p4=plot(
		plts...,
		size=(1000,1000),
		layout=(4,4),
		legend=false,
		markersize=3,
		markeralpha = 0.4,
		markerstrokewidth = 0.2,
    	markerstrokealpha = 0.2,
		font=10
	)
	xlabel!(":DATE")
	ylabel!(":DTMIN_C (°C)")
end

# ╔═╡ 0d6eaf2b-5f63-4140-92e4-23354dd466c9
md"""
Efetivamente, esses *outlier* referem-se a erros de leitura ou registo nas datas especificadas.

O impacto da ausência desses pontos pode ser medido em algum experimento.

Recomendo que sejam feitas predições utilizando um recorte cronológico onde *outliers* não aparecem, e os resultados sejam comparados com os de outros experimentos que utilizem um recorte cronológico mais extenso que envolva um periódo com dados faltantes. 

O objetivo seria determinar:
*O que é melhor para a capacidade preditiva do modelo ? Usar um menor intervalo de para a predição sem dados faltantes, ou usar um intervalo de tempo consideravelmente maior mas com dados faltantes?*

Notei que os dados parecem mais estáveis de 2019 em diante. Penso que a princípio possam ser utilizados como padrão. 
"""

# ╔═╡ 7cc1290e-3531-4057-8481-2a7fca7b2963
begin
	new_fdados = statusINMET();
	new_dados = obter_dados(new_fdados, ["FORMIGA"], 2019:2023)
	ajst_colnames!(new_dados);
	treat_data!(new_dados);
end

# ╔═╡ fd71b0f7-e346-4960-acb9-7d139fc5d507
begin
	#concatenação das séries
	using DataFrames
	new_df = vcat([i.dataset for i in new_dados.serie]...);
	filter!(:ADSOLPW => n -> n > 0., new_df)
end

# ╔═╡ 57df07be-89e9-4e62-948a-158f294d1a0c
md"""
## Empilhamento de dados para o processo de *outlier detection", *forecasting* e persistência

Até este ponto não usamos recurso de persistência de dados para o armazenamento das séries. 

Uma função mais especializada nestas séries já está sendo implementada em um *branch* pessoal do pacote, no entanto para este trabalho faremos isso criando um arquivo `.csv` simples para armazenar todos as séries de forma contínua. Para a utilização 
do método ARIMA sasonal utilizaremos apenas as colunas `:DATE` e `:ADSOLPW`.
"""

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

# ╔═╡ c9e64e6d-3833-4c5b-a821-998675a2faac
md"""
### Identificação de *outliers*
Para identificar os *outliers* utilizaremos uma técnica denominada *Distance-based outliers* proposta por *Knorr* e *Ng* (2000), cite a obra abaixo para referenciar a técnica. 

```
@article{knorr2000distance,
  title={Distance-based outliers: algorithms and applications},
  author={Knorr, Edwin M and Ng, Raymond T and Tucakov, Vladimir},
  journal={The VLDB Journal},
  volume={8},
  number={3},
  pages={237--253},
  year={2000},
  publisher={Springer}
}
```

Efetivamente este método é uma versão simplificada do algoritmo de *Machine Learning* denominado *k-nearest neighbors*.
"""

# ╔═╡ 1b6333da-b123-4083-ab58-8a5827833fb4
md"""
No futuro implementarei uma forma automatizada deste recurso no pacote, mas como estamos sem tempo no momento fica desta forma.

O processo inicia-se com a instalação dos pacotes `MLJ` e `OutlierDetection`, se for a primeira execução deste notebook.
"""

# ╔═╡ 90b0d427-b2e2-45ef-aa3f-4dedd1880837
#=
begin 
	Pkg.add("MLJ")
	Pkg.add("OutlierDetection")
end
=#

# ╔═╡ dfceaae7-807f-4876-88c4-9f008015bb40
md"Faz-se a importação das bibliotecas"

# ╔═╡ d97be736-1986-4811-a273-7eff5252fb84
md"""
Em seguida faz-se a criação do modelo de identificação dos *outliers*.
"""

# ╔═╡ 34418083-6b43-4777-a512-7074030341ec
begin
	KNN = @iload KNNDetector pkg=OutlierDetectionNeighbors
	knn = KNN()
end

# ╔═╡ ec55f10a-288c-4af4-8867-359da2bc266a
md"O pacote OutlierDetection, disponibiliza uma máquina de predição que cria o modelo de predição, este por sua vez é passado ao método de treinamento que efetivamente identifica os pontos. Note que apenas as colunas de dados são passadas, as datas não."

# ╔═╡ e21e3ec9-b89b-404c-82b4-ab2c440c5f1d
knn_classifier = machine(DeterministicDetector(knn), select(new_df, Not(:DATE))) |> fit!

# ╔═╡ 04df6dda-0441-4d27-88af-f9d814b05f6b
md"A predição dos *outliers* é feita da seguinte forma."

# ╔═╡ 779b7c7d-e276-44bd-a6ee-5de73dea57cf
outliers = predict(knn_classifier)

# ╔═╡ a7979ffd-cf84-474d-a4fa-37fc5da607e2
md"Aqui adicionamos uma nova coluna aos nossos dados que contem a categoria de cada linha, ou seja, se o ponto em questão é um *outlier* ou normal."

# ╔═╡ 21897d29-bee3-4eee-a368-41ca17d337da
df_new = hcat(new_df, DataFrame([String.(outliers)], [:OUTLIER_YN]));

# ╔═╡ 7a3441c9-8f3a-4d99-8f35-c9a8bfe17bb4
begin
	using CSV

	filter!(:OUTLIER_YN => n -> n == "normal", df_new)
	filter!(:ADSOLPW => n -> n > 0., df_new)
	CSV.write("DataForm2010To2023.csv", df_new)
end

# ╔═╡ 78b5659c-3487-4c2a-bd70-18befdf94efb
md"A data frame `df_new` agora contém os dados e as categorias de cada linha."

# ╔═╡ 49f3ad0c-280a-4ce3-9529-741cf495d7af
first(df_new, 50)

# ╔═╡ d6dc8762-8bd9-4977-934d-ba2fb0b97151
md"Distinguindo graficamente o trabalho da máquina de predição de *outliers."

# ╔═╡ 779378ea-3240-41ab-8a82-6db061966a71
scatter(
	df_new[df_new.OUTLIER_YN .== "normal",:DATE], 
	df_new[df_new.OUTLIER_YN .== "normal", :ADSOLPW],
	label = "Normal points",
	legend=true, 
	markersize=3,
	markeralpha = 1,
	markerstrokewidth = 0.2,
    markerstrokealpha = 0.2,
	font=10
)

# ╔═╡ e2bcb368-7066-4060-b9f7-0d2b6ef24b97
begin
	scatter!(
		df_new[df_new.OUTLIER_YN .== "outlier",:DATE], 
		df_new[df_new.OUTLIER_YN .== "outlier", :ADSOLPW],
		label = "Outlier points",
		legend=true, 
		markersize=3,
		markeralpha = 0.6,
		markerstrokewidth = 0.2,
    	markerstrokealpha = 0.2,
		font=10
	)
	xlabel!("Data da Medida")
	ylabel!("Radiação Solar log[kJ/m²]")
end

# ╔═╡ c3c776a0-510a-4695-aede-4ab597219362
md"""
Agora podemos filtrar os dados confiáveis para o estudo subtraindo de `new_df` os *outliers*, além disso, vamos pegar apenas os valores de radiação solar maiores que zero.
Salvando os dados em formato `.csv`, se necessário adicione o pacote CSV.
"""

# ╔═╡ 28aac581-a3a3-4b28-b052-fd277289507a
#Pkg.add("CSV")

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
# ╠═fa07a25f-25b3-4bdd-9b0a-00b279e09391
# ╠═8a46c032-afcb-4dd8-9792-112f432bb3cd
# ╠═3478bc11-1152-4e58-b43c-a89e69c9e1bc
# ╠═4eb197bc-6a32-48a5-be6a-e1b954451317
# ╠═7e84fdf7-f87e-456a-b994-424dac495344
# ╠═0d6eaf2b-5f63-4140-92e4-23354dd466c9
# ╠═7cc1290e-3531-4057-8481-2a7fca7b2963
# ╠═57df07be-89e9-4e62-948a-158f294d1a0c
# ╠═fd71b0f7-e346-4960-acb9-7d139fc5d507
# ╠═2f2c234b-25b1-47d3-a931-06cf9c9d884c
# ╠═0a3b911b-ef65-4b1e-83e2-3f4c8623a029
# ╠═e29cf5c1-370e-4bf7-b09b-817eeeb9e822
# ╠═c9e64e6d-3833-4c5b-a821-998675a2faac
# ╠═1b6333da-b123-4083-ab58-8a5827833fb4
# ╠═90b0d427-b2e2-45ef-aa3f-4dedd1880837
# ╠═dfceaae7-807f-4876-88c4-9f008015bb40
# ╠═2256deca-9b41-4390-91ce-f0eebfbf92d3
# ╠═d97be736-1986-4811-a273-7eff5252fb84
# ╠═34418083-6b43-4777-a512-7074030341ec
# ╠═ec55f10a-288c-4af4-8867-359da2bc266a
# ╠═e21e3ec9-b89b-404c-82b4-ab2c440c5f1d
# ╠═04df6dda-0441-4d27-88af-f9d814b05f6b
# ╠═779b7c7d-e276-44bd-a6ee-5de73dea57cf
# ╠═a7979ffd-cf84-474d-a4fa-37fc5da607e2
# ╠═21897d29-bee3-4eee-a368-41ca17d337da
# ╠═78b5659c-3487-4c2a-bd70-18befdf94efb
# ╠═49f3ad0c-280a-4ce3-9529-741cf495d7af
# ╠═d6dc8762-8bd9-4977-934d-ba2fb0b97151
# ╠═779378ea-3240-41ab-8a82-6db061966a71
# ╠═e2bcb368-7066-4060-b9f7-0d2b6ef24b97
# ╠═c3c776a0-510a-4695-aede-4ab597219362
# ╠═28aac581-a3a3-4b28-b052-fd277289507a
# ╠═7a3441c9-8f3a-4d99-8f35-c9a8bfe17bb4
