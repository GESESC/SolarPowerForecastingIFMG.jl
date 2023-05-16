### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ c9733a26-6294-478b-8a8c-fdc2d0a5eb50
begin
	using Pkg
	Pkg.activate("/home/reginaldo/Insync/Trabalho/IFMG/IFMG_ARCOS/TCCs/TCCVitinho/SolarPowerForecastingIFMG.jl/Test/dev_env")
end

# ╔═╡ 5c727255-8048-48cd-a936-ae07ea825bf3
Pkg.add("Forecast")

# ╔═╡ 10578541-40b5-4ed1-a42f-80cb1a6bd61f
using CSV, DataFrames

# ╔═╡ 1b24b467-4f29-4b38-9ba9-93c3d5a73749
using SolarPowerForecastingIFMG.TruncagemDeDados: split_df

# ╔═╡ 1a3e9cf3-a70c-43d6-a437-711c467e003b
using StateSpaceModels, Forecast

# ╔═╡ da0be4a8-f412-11ed-3cf4-2f2491c97b63
md"""
# TCC - Victor Gonçalves
## Técnicas de *Forecasting*
Autor: Prof. Dr. Reginaldo Gonçalves Leão Junior

No processo de tratamento dos *outliers* criamos um arquivo `.csv` para o armazenamento dos dados salvos, iniciaremos pelo carregamento deste arquivo mais uma vez na memória e separação dos dados de treinamento e teste.
"""

# ╔═╡ ceef7372-7e9b-4c4e-bd5b-803918521e28
md"## Training Set e Test Set"

# ╔═╡ 0ce0f62f-4c3d-456a-8421-1869d5bb03bd
df = CSV.read("/home/reginaldo/Insync/Trabalho/IFMG/IFMG_ARCOS/TCCs/TCCVitinho/SolarPowerForecastingIFMG.jl/Examples/plutonotebooks/DataForm2010To2023.csv", DataFrame);

# ╔═╡ 97c596e8-413c-4a0b-9a0c-7192ed313ddc
md"Agora, usando a função `split_df` de nosso pacote, vamos dividir a série em *training set* e *test set*."

# ╔═╡ fa1b757f-f13d-4d38-bef3-d61795c78070
trs_df, tst_df = split_df(df)

# ╔═╡ c3a7bd86-ec7c-4047-8460-d2d3487aea13
begin
	using Plots
	gr()
	scatter(
		trs_df[!,:DATE], 
		trs_df[!, :ADSOLPW],
		label="Training Set",
		legend=true, 
		markersize=3,
		markeralpha = 0.6,
		markerstrokewidth = 0.2,
    	markerstrokealpha = 0.2,
		font=10
	)
	scatter!(
		tst_df[!,:DATE], 
		tst_df[!, :ADSOLPW], 
		label="Test Set",
		legend=true, 
		markersize=3,
		markeralpha = 0.6,
		markerstrokewidth = 0.2,
    	markerstrokealpha = 0.2,
		font=10
	)
	xlabel!("Data da Medida")
	ylabel!("Radiação Solar[kJ/m²]")
end

# ╔═╡ 41897928-3b19-4438-9978-3035a0e365db
md"O processo de divisão pode ser inspecionado visualmente."

# ╔═╡ 6765d277-7871-4506-9ec3-7fb5dc85424a
md"#Decomposição da Série."

# ╔═╡ 096fb652-5227-4365-82b0-708838bba139


# ╔═╡ ee63347e-8a1d-42a9-a2bd-f738d858e056
model = UnobservedComponents(log.(trs_df[!,:ADSOLPW]); trend = "local level", cycle = "stochastic")

# ╔═╡ d4bcb812-f73e-4557-81b7-454b09c849a4
fit!(model)

# ╔═╡ 8e12a5c8-251a-4a18-9e18-fbbca7ad2625
ks = kalman_smoother(model)

# ╔═╡ 194a42de-9c84-4e30-af97-ed4d52422982
plot(model)

# ╔═╡ e7716c95-d8d8-424f-a8a9-ab4ab6411268
plot(model, ks)

# ╔═╡ 21776668-b9e8-4177-a19e-757c791ebf23


# ╔═╡ 0e3ca447-c2a6-41ef-b5f4-c9b0ae241c60
kf = kalman_filter(model)

# ╔═╡ 658d8991-ce79-44c3-86f7-2d36614695a2
plotdiagnostics(kf)

# ╔═╡ 4e6296da-b2a1-4747-831b-38f5122b381f


# ╔═╡ 018599a0-293b-41c1-8cf5-4600f79b20e5


# ╔═╡ dc75aed7-ed6e-4f29-8b7c-2032ae914337


# ╔═╡ Cell order:
# ╠═da0be4a8-f412-11ed-3cf4-2f2491c97b63
# ╠═c9733a26-6294-478b-8a8c-fdc2d0a5eb50
# ╠═ceef7372-7e9b-4c4e-bd5b-803918521e28
# ╠═10578541-40b5-4ed1-a42f-80cb1a6bd61f
# ╠═0ce0f62f-4c3d-456a-8421-1869d5bb03bd
# ╠═97c596e8-413c-4a0b-9a0c-7192ed313ddc
# ╠═1b24b467-4f29-4b38-9ba9-93c3d5a73749
# ╠═fa1b757f-f13d-4d38-bef3-d61795c78070
# ╠═41897928-3b19-4438-9978-3035a0e365db
# ╠═c3a7bd86-ec7c-4047-8460-d2d3487aea13
# ╠═5c727255-8048-48cd-a936-ae07ea825bf3
# ╠═6765d277-7871-4506-9ec3-7fb5dc85424a
# ╠═1a3e9cf3-a70c-43d6-a437-711c467e003b
# ╠═096fb652-5227-4365-82b0-708838bba139
# ╠═ee63347e-8a1d-42a9-a2bd-f738d858e056
# ╠═d4bcb812-f73e-4557-81b7-454b09c849a4
# ╠═8e12a5c8-251a-4a18-9e18-fbbca7ad2625
# ╠═194a42de-9c84-4e30-af97-ed4d52422982
# ╠═e7716c95-d8d8-424f-a8a9-ab4ab6411268
# ╠═21776668-b9e8-4177-a19e-757c791ebf23
# ╠═0e3ca447-c2a6-41ef-b5f4-c9b0ae241c60
# ╠═658d8991-ce79-44c3-86f7-2d36614695a2
# ╠═4e6296da-b2a1-4747-831b-38f5122b381f
# ╠═018599a0-293b-41c1-8cf5-4600f79b20e5
# ╠═dc75aed7-ed6e-4f29-8b7c-2032ae914337
