### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ c590e23a-f7d7-11ed-00c5-090aac28e1b8
begin
	using Pkg
	Pkg.activate("/home/reginaldo/Insync/Trabalho/IFMG/IFMG_ARCOS/TCCs/TCCVitinho/SolarPowerForecastingIFMG.jl/Test/dev_env")
end

# ╔═╡ 2ee79b68-9c78-471f-a6c0-e4986858d29d
begin
	using MLJ
	using OutlierDetection
	using OutlierDetectionData: ODDS
end

# ╔═╡ b5ba2173-0624-4bb3-b431-502abab82189
# download and open the thyroid benchmark dataset
X, y = ODDS.load("thyroid")

# ╔═╡ 248c273e-4473-4bdb-9727-b83a4d48207e
X

# ╔═╡ ec0d0b9a-2361-4c60-b9a8-693d74791f41
train, test = partition(eachindex(y), 0.5, shuffle=true)

# ╔═╡ b36e57de-4075-455f-a96e-424ee1d7491b
KNN = @iload KNNDetector pkg=OutlierDetectionNeighbors;

# ╔═╡ 0a7b810a-77f3-465f-b6f8-4567d9a51c27
knn = KNN()

# ╔═╡ 9d38fa4a-fc56-4c24-a9be-182eb1194923
knn_raw = machine(knn, X) |> fit!

# ╔═╡ 65843057-c0df-4809-ba18-5e3d05a33350
transform(knn_raw, rows=test)

# ╔═╡ a6f19a61-ce48-412a-8a96-9b71d98d40c2
knn_probas = machine(ProbabilisticDetector(knn), X) |> fit!

# ╔═╡ a4a1ffe0-f492-47ab-b5b2-9e796d8a0950
predict(knn_probas, rows=test)

# ╔═╡ cf00e3f8-83fe-43d3-9225-2048cacdcd26
knn_probas

# ╔═╡ f6fec510-b921-4e77-8c41-0859486d4155
knn_classifier = machine(DeterministicDetector(knn), X) |> fit!

# ╔═╡ 5efd5a8c-854c-408d-84e4-80a32cfaaba5
predict(knn_classifier, rows=test)

# ╔═╡ Cell order:
# ╠═c590e23a-f7d7-11ed-00c5-090aac28e1b8
# ╠═2ee79b68-9c78-471f-a6c0-e4986858d29d
# ╠═b5ba2173-0624-4bb3-b431-502abab82189
# ╠═248c273e-4473-4bdb-9727-b83a4d48207e
# ╠═ec0d0b9a-2361-4c60-b9a8-693d74791f41
# ╠═b36e57de-4075-455f-a96e-424ee1d7491b
# ╠═0a7b810a-77f3-465f-b6f8-4567d9a51c27
# ╠═9d38fa4a-fc56-4c24-a9be-182eb1194923
# ╠═65843057-c0df-4809-ba18-5e3d05a33350
# ╠═a6f19a61-ce48-412a-8a96-9b71d98d40c2
# ╠═a4a1ffe0-f492-47ab-b5b2-9e796d8a0950
# ╠═cf00e3f8-83fe-43d3-9225-2048cacdcd26
# ╠═f6fec510-b921-4e77-8c41-0859486d4155
# ╠═5efd5a8c-854c-408d-84e4-80a32cfaaba5
