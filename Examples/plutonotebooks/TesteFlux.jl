### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ abab40f4-f836-11ed-2a23-3f25c5ff92fd
begin
	using Pkg
	Pkg.activate("/home/reginaldo/Insync/Trabalho/IFMG/IFMG_ARCOS/TCCs/TCCVitinho/SolarPowerForecastingIFMG.jl/Test/dev_env")
end

# ╔═╡ d7de2de4-27e7-4464-ad47-80d7e8e34af9
Pkg.add("Flux")

# ╔═╡ 2aca5614-e3b3-4fbf-a40e-b3286d1349da
using CSV, DataFrames

# ╔═╡ 63bf260c-7222-4153-a508-fbc1cf71996e
using Flux

# ╔═╡ e546881d-2b0a-4b8b-a27e-fbbad765fa04
using SolarPowerForecastingIFMG.TruncagemDeDados

# ╔═╡ 05cda84a-b134-4eba-8d37-e7a159e9fd67
df = CSV.read("/home/reginaldo/Insync/Trabalho/IFMG/IFMG_ARCOS/TCCs/TCCVitinho/SolarPowerForecastingIFMG.jl/Examples/plutonotebooks/DataForm2010To2023.csv",DataFrame)

# ╔═╡ 4f5e20ca-1ef5-4af5-a7c4-a66224732543
train, test = split_df(df)

# ╔═╡ 709eb160-68f2-4520-a91f-ee3a0f1eedc6
rnn = Flux.RNNCell(4,1)

# ╔═╡ 6511e6c6-376c-4ff6-86ef-5877ccf99f11
model = Flux.Recur(rnn, train[!, Not([:DATE, :OUTLIER_YN])])

# ╔═╡ dcfe3fac-092c-443b-b854-d5847f41812c
predito = model(train[!,:DATE])

# ╔═╡ 87ca19c6-e041-4a77-86af-2c93467b3d83


# ╔═╡ Cell order:
# ╠═abab40f4-f836-11ed-2a23-3f25c5ff92fd
# ╠═d7de2de4-27e7-4464-ad47-80d7e8e34af9
# ╠═2aca5614-e3b3-4fbf-a40e-b3286d1349da
# ╠═05cda84a-b134-4eba-8d37-e7a159e9fd67
# ╠═63bf260c-7222-4153-a508-fbc1cf71996e
# ╠═e546881d-2b0a-4b8b-a27e-fbbad765fa04
# ╠═4f5e20ca-1ef5-4af5-a7c4-a66224732543
# ╠═709eb160-68f2-4520-a91f-ee3a0f1eedc6
# ╠═6511e6c6-376c-4ff6-86ef-5877ccf99f11
# ╠═dcfe3fac-092c-443b-b854-d5847f41812c
# ╠═87ca19c6-e041-4a77-86af-2c93467b3d83
