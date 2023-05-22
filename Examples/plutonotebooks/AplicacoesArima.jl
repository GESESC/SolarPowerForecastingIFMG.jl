### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ c9733a26-6294-478b-8a8c-fdc2d0a5eb50
begin
	using Pkg
	Pkg.activate("/home/reginaldo/Insync/Trabalho/IFMG/IFMG_ARCOS/TCCs/TCCVitinho/SolarPowerForecastingIFMG.jl/Test/dev_env")
end

# ╔═╡ 10578541-40b5-4ed1-a42f-80cb1a6bd61f
using CSV, DataFrames

# ╔═╡ 1b24b467-4f29-4b38-9ba9-93c3d5a73749
using SolarPowerForecastingIFMG.TruncagemDeDados: split_df

# ╔═╡ 0d5eb1c9-4c31-4334-914d-f8201d844dd4
begin
	using MLJ
	using OutlierDetection
end

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

# ╔═╡ d89726de-3ab1-45f4-95b9-52fa34827f50
begin
	KNN = @iload KNNDetector pkg=OutlierDetectionNeighbors
	knn = KNN()
end

# ╔═╡ 7419d18b-54ed-46da-96d6-8f68a51e1fcd
knn_classifier = machine(DeterministicDetector(knn), select(df, Not(:DATE))) |> fit!

# ╔═╡ 8c309105-1cb0-419b-b22a-7b023a75af84
outliers = predict(knn_classifier)

# ╔═╡ a6946d0c-3df8-4d75-aca9-3b0f2694839e


# ╔═╡ 5ab04a57-6ae4-4a82-87fb-6b78899e7f8a
df_new = hcat(df, DataFrame([String.(outliers)], [:OUTLIER_YN]))

# ╔═╡ 41897928-3b19-4438-9978-3035a0e365db
md"O processo de divisão pode ser inspecionado visualmente."

# ╔═╡ 6765d277-7871-4506-9ec3-7fb5dc85424a
md"#Decomposição da Série."

# ╔═╡ b145f87f-db82-4f8b-9e9b-3e68d3fc99f2
model = auto_arima(trs_df[!, :ADSOLPW])

# ╔═╡ ab8e80a4-c736-4ac1-8417-e1a78cfe9c68
fit!(model)

# ╔═╡ 7c18eb0e-ef92-4c39-9f34-277244c3c28d
model

# ╔═╡ b9d374ff-f022-4b67-af71-b36c72efa66e
forec = forecast(model, 1000)

# ╔═╡ 1a9c5292-6a7e-4260-b674-8226cb6d697d
plot(model, forec; legend = :topleft)

# ╔═╡ 27440268-cbad-4f73-ae65-150466167949
plot!(tst_df[!,:DATE], 
		tst_df[!, :ADSOLPW], 
		label="Test Set",)

# ╔═╡ Cell order:
# ╠═da0be4a8-f412-11ed-3cf4-2f2491c97b63
# ╠═c9733a26-6294-478b-8a8c-fdc2d0a5eb50
# ╠═ceef7372-7e9b-4c4e-bd5b-803918521e28
# ╠═10578541-40b5-4ed1-a42f-80cb1a6bd61f
# ╠═0ce0f62f-4c3d-456a-8421-1869d5bb03bd
# ╠═97c596e8-413c-4a0b-9a0c-7192ed313ddc
# ╠═1b24b467-4f29-4b38-9ba9-93c3d5a73749
# ╠═0d5eb1c9-4c31-4334-914d-f8201d844dd4
# ╠═d89726de-3ab1-45f4-95b9-52fa34827f50
# ╠═7419d18b-54ed-46da-96d6-8f68a51e1fcd
# ╠═8c309105-1cb0-419b-b22a-7b023a75af84
# ╠═a6946d0c-3df8-4d75-aca9-3b0f2694839e
# ╠═5ab04a57-6ae4-4a82-87fb-6b78899e7f8a
# ╠═41897928-3b19-4438-9978-3035a0e365db
# ╠═c3a7bd86-ec7c-4047-8460-d2d3487aea13
# ╠═6765d277-7871-4506-9ec3-7fb5dc85424a
# ╠═b145f87f-db82-4f8b-9e9b-3e68d3fc99f2
# ╠═ab8e80a4-c736-4ac1-8417-e1a78cfe9c68
# ╠═7c18eb0e-ef92-4c39-9f34-277244c3c28d
# ╠═b9d374ff-f022-4b67-af71-b36c72efa66e
# ╠═1a9c5292-6a7e-4260-b674-8226cb6d697d
# ╠═27440268-cbad-4f73-ae65-150466167949
