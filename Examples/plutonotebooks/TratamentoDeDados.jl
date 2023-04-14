### A Pluto.jl notebook ###
# v0.19.24

using Markdown
using InteractiveUtils

# ╔═╡ 23de5c62-6c49-4c2c-ab65-dcf16d0b035b
begin
	using Pkg
	Pkg.activate("/home/reginaldo/Insync/Trabalho/IFMG/IFMG_ARCOS/TCCs/TCCVitinho/SolarPowerForecastingIFMG.jl/Test/dev_env")
	#Pkg.update()
end

# ╔═╡ 0187dd15-eab5-4104-9f55-3ca8276c28db
using SolarPowerForecastingIFMG.RaspagemDeDadosINMET, SolarPowerForecastingIFMG.TruncagemDeDados, DataFrames

# ╔═╡ c3a96d00-d75c-4606-87b7-ebe70bf397b7
begin
	using Plots
	gr()
end

# ╔═╡ 57fdd56c-adf3-11ed-15f8-495dfdad0b57
md"""
# TCC - Victor Gonçalves
## Instruções para tratamento de dados
Autor: Prof. Dr. Reginaldo Gonçalves Leão Junior
"""

# ╔═╡ 4b4fb2d8-48a1-4597-982c-80466dd2d81e
md"""Ativação do pacote."""

# ╔═╡ 5d7cc2d7-7e8d-4f2d-9b95-86bdf173150b
md"""Importando pacotes"""

# ╔═╡ 385abc2c-a4e6-44b2-8a12-4f5a125d5cd1
md"""Consultando a fonte de dados, baixando e ajustando os nomes das colunas."""

# ╔═╡ d799e0fc-99cf-44da-b703-c90eb1d6677a
begin
	fonte_dados = statusINMET();
	dados = obter_dados(fonte_dados, ["FORMIGA"], [2019]);
	ajst_colnames!(dados);
end

# ╔═╡ 10283bea-9b67-41f2-bf6c-c76f2c04dc26
md"""
Os dados crús devem ser tratados com o objetivo de:

1. Retirar colunas que não são necessárias no modelo;
2. Renomear as colunas trocando os nomes tipo *string* para o tipo *symbol*;
3. Tratar os dados faltantes (*missings*);
4. Integrar os dados diários.

Na versão atual do modelo, foi implementado o método `treat_data!()` que realiza todas essas tarefas de forma automatizada. 

Verifique a documentação via *Live Docs*.
"""

# ╔═╡ 7b200f79-3552-4773-9107-a44ad1c69119
treat_data!(dados);

# ╔═╡ 23c75a65-3d89-4a15-8156-17bf9ba95800
md"""
Feito isto, é possível observar que a estrutura dados agora contém *datasets* totalmente redimensionados.

Na listagem abaixo são mostradas as primeiras e últimas cinco linhas do novo *dataset*.
"""

# ╔═╡ 38f66ac7-1a9d-473f-a81c-d0648255a46a
first(dados.serie[1].dataset, 5)

# ╔═╡ f41f23e1-c5d2-4c65-8ab5-55f2699702ff
last(dados.serie[1].dataset, 5)

# ╔═╡ 69cbdd31-4f9a-4212-9d82-6cb70e33c5eb
md"""
Note que duas coisas devem ser observadas, a mais aparente a mudança na nomenclatura das colunas. Após o tratamento dos dados não são usadas *strings* para a nomeação das colunas, mas símbolos de Julia, o que facilita a referência às *features*.
para de obter a incidência solar diária acumulada `ADSOLPW` basta se fazer:
"""

# ╔═╡ b15f940d-3f50-4772-9d20-e952282cb5a0
dados.serie[1].dataset.ADSOLPW

# ╔═╡ 8d59507a-5bae-4a0c-966c-2062ea8894ff
md"""
E o mesmo para as demais colunas.

Uma avaliação anual da variação da incidência solar poderia ser obtida, por exemplo se fazendo.
"""

# ╔═╡ 4642f870-2805-495f-97d6-1115f8328172
begin
	plot(dados.serie[1].dataset.DATE, dados.serie[1].dataset.ADSOLPW, label=false)
	xlabel!("Data")
	ylabel!("Radiação Global Acumuluada (KJ/m²)")
end

# ╔═╡ a4a8756e-bcaf-44c7-8419-9460c9a3ce40
md"""
Um exemplo um pouco mais instrutivo seria a determinação da correlação entre colunas do *dataset*.

Suponha que se queira apreciar a correlação entre a máxima temperatura diária e a radiação global acumulada no dia.

"""

# ╔═╡ 907eff22-9cdf-48c2-af1f-8b8e15e99499
begin
	scatter(dados.serie[1].dataset.DTMAX_C, dados.serie[1].dataset.ADSOLPW, label=false)
	xlabel!("Temperatura diária máxima (°C)")
	ylabel!("Radiação Global Acumuluada (KJ/m²)")
end

# ╔═╡ 9d1cf666-9f2b-475c-b9c2-b9407f713aab
md""" Avaliações estatísticas mais precisas serão apresentadas nos próximos notebook."""

# ╔═╡ 5ebe0af6-8fc2-4743-9863-92b4542bdc59
md"""
### Truncagem do *dataset*

Para o treinamento do modelo geralmente se divide as sérias em *train set* e *test set* a primeira para o treinamento propriamente dito e a segunda para a validação. 

O método `split_df()` do módulo `TruncagemDeDado` do pacote faz esse trabalho.
"""

# ╔═╡ 32a80cdd-4965-4289-9f1e-c33d1ece841a
train_set, test_set = split_df(dados.serie[1].dataset);

# ╔═╡ c2212416-9040-45ec-8784-9cf82efd29d5
first(train_set, 5)

# ╔═╡ d7ad8d2d-ae50-4802-9ef4-ca51ce2b38c7
first(test_set, 5)

# ╔═╡ ea5e5e75-7529-4ea0-a6b2-f3a26d4b1918
md"""
A suficiência do método pode ser verificada apreciando-se visualmente a distribuição entre os dois *datasets*.
"""

# ╔═╡ 6b7459bb-abdf-46ad-b3a7-232e5adea873
begin
	plot(
		train_set.DATE, 
		train_set.ADRAIN,
		xlabel = "Data",
		ylabel = "Pluviosidade diária acumulada mm",
		label="train"
	) 
 	plot!(
		test_set.DATE, 
		test_set.ADRAIN,
		xlabel = "Data",
		ylabel = "Pluviosidade diária acumulada (mm)",
		ma=0.6,
		ms=2.5,
	label="test"
	)
end


# ╔═╡ 2f71f846-b0c0-430d-8aa1-af69237d56a5
begin
	plot(
		train_set.DATE, 
		train_set.ADSOLPW,
		xlabel = "Data",
		ylabel = "Radiação Global Diária Acumuluada (KJ/m²)",
		label="train"
	) 
 	plot!(
		test_set.DATE, 
		test_set.ADSOLPW,
		xlabel = "Data",
		ylabel = "Radiação Global Diária Acumuluada (KJ/m²)",
		ma=0.6,
		ms=2.5,
	label="test"
	)
end

# ╔═╡ a6d855d9-b29a-4328-8ae4-57c6bdc3ee7a
begin
	plot(
		train_set.DATE, 
		train_set.DTMAX_C,
		xlabel = "Data",
		ylabel = "Temperatura (°C)",
		label="Máxima diária - train"
	)
	plot!(
		train_set.DATE, 
		train_set.DTMIN_C,
		xlabel = "Data",
		ylabel = "Temperatura (°C)",
		label="Mínima diária - train"
	) 
	plot!(
		test_set.DATE, 
		test_set.DTMAX_C,
		xlabel = "Data",
		ylabel = "Temperatura (°C)",
		label="Máxima diária - test",
		ma=0.6,
		ms=2.5,
	)
	plot!(
		test_set.DATE, 
		test_set.DTMIN_C,
		xlabel = "Data",
		ylabel = "Temperatura (°C)",
		label="Mínima diária - test",
		ma=0.6,
		ms=2.5
	) 
end

# ╔═╡ Cell order:
# ╠═57fdd56c-adf3-11ed-15f8-495dfdad0b57
# ╟─4b4fb2d8-48a1-4597-982c-80466dd2d81e
# ╠═23de5c62-6c49-4c2c-ab65-dcf16d0b035b
# ╟─5d7cc2d7-7e8d-4f2d-9b95-86bdf173150b
# ╠═0187dd15-eab5-4104-9f55-3ca8276c28db
# ╟─385abc2c-a4e6-44b2-8a12-4f5a125d5cd1
# ╠═d799e0fc-99cf-44da-b703-c90eb1d6677a
# ╟─10283bea-9b67-41f2-bf6c-c76f2c04dc26
# ╠═7b200f79-3552-4773-9107-a44ad1c69119
# ╟─23c75a65-3d89-4a15-8156-17bf9ba95800
# ╠═38f66ac7-1a9d-473f-a81c-d0648255a46a
# ╠═f41f23e1-c5d2-4c65-8ab5-55f2699702ff
# ╟─69cbdd31-4f9a-4212-9d82-6cb70e33c5eb
# ╠═b15f940d-3f50-4772-9d20-e952282cb5a0
# ╠═8d59507a-5bae-4a0c-966c-2062ea8894ff
# ╠═c3a96d00-d75c-4606-87b7-ebe70bf397b7
# ╠═4642f870-2805-495f-97d6-1115f8328172
# ╠═a4a8756e-bcaf-44c7-8419-9460c9a3ce40
# ╠═907eff22-9cdf-48c2-af1f-8b8e15e99499
# ╟─9d1cf666-9f2b-475c-b9c2-b9407f713aab
# ╟─5ebe0af6-8fc2-4743-9863-92b4542bdc59
# ╠═32a80cdd-4965-4289-9f1e-c33d1ece841a
# ╠═c2212416-9040-45ec-8784-9cf82efd29d5
# ╠═d7ad8d2d-ae50-4802-9ef4-ca51ce2b38c7
# ╟─ea5e5e75-7529-4ea0-a6b2-f3a26d4b1918
# ╠═6b7459bb-abdf-46ad-b3a7-232e5adea873
# ╠═2f71f846-b0c0-430d-8aa1-af69237d56a5
# ╠═a6d855d9-b29a-4328-8ae4-57c6bdc3ee7a
