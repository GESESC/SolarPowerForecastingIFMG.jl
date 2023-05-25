### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ abab40f4-f836-11ed-2a23-3f25c5ff92fd
begin
	using Pkg
	Pkg.activate("/home/reginaldo/Documentos/SolarPowerForecastingIFMG.jl/Test/dev_env")
end

# ╔═╡ 7d4a87ae-51c5-4101-8bbf-64da2b5a1c0f
using Flux, Plots, CSV, DataFrames, SolarPowerForecastingIFMG.TruncagemDeDados

# ╔═╡ f7d97ecb-dffd-4310-a138-1e865efb1be3
data = CSV.read("/home/reginaldo/Documentos/SolarPowerForecastingIFMG.jl/Examples/plutonotebooks/DataForm2010To2023.csv", DataFrame)

# ╔═╡ 26ea351d-51b1-4f0d-a0c9-a829fcbcd8c4
train, test = split_df(data[!, Not([:DATE, :OUTLIER_YN])])

# ╔═╡ e0b364bc-1bf2-4e4a-a9cf-aa84cf8e12ef
function form_data(r_df)
	vals = Float32.(values(r_df))
	vals = getindex(vals, [2,1,3,4])
	return vals
	#return reshape([vals...], (4,1))
end

# ╔═╡ d8da6f71-b414-4619-aa4a-1b9fb1a16df3
nw_train = [form_data(i) for i in eachrow(train)]
#nw_train = Flux.DataLoader((train[!,:ADSOLPW], train[!,Not(:ADSOLPW)]), batchsize=4)

# ╔═╡ 07f5031a-d1c1-4de9-ad54-9f49b57a8304
obsrv, features = size(train)

# ╔═╡ e3b532d5-2ff1-49df-9e2d-7e204ad35856
model = Chain(
	LSTM(features => 10),
	LSTM(10 => 1)
)

# ╔═╡ a1a7a7e7-ab61-4ecb-b59f-e367202b0d6d
params = Flux.params(model)

# ╔═╡ cbf60840-f8c3-456b-ac1e-b99603dac13e
opt = Flux.setup(Adam(), model)

# ╔═╡ 3f40b150-98c9-4bb9-9846-668fc30ff401
loss(x, y) = sum((model(x) .- y).^2)

# ╔═╡ 6c10f679-1482-4deb-9665-7ece6e6380de
for d in nw_train
	println(size(d, 1))
	grads = Flux.gradient(model) do m
		result = m([d...])
		loss(result, d[1])
	end
	Flux.update!(opt, model, grads[1])
end

# ╔═╡ 4267d684-d727-4446-8b4f-25836aa3babf
# ╠═╡ disabled = true
#=╠═╡
a = (1,2,3)
  ╠═╡ =#

# ╔═╡ b44ec80a-0d9d-4544-b341-15231e0f8293
#=╠═╡
[a...]
  ╠═╡ =#

# ╔═╡ Cell order:
# ╠═abab40f4-f836-11ed-2a23-3f25c5ff92fd
# ╠═7d4a87ae-51c5-4101-8bbf-64da2b5a1c0f
# ╠═f7d97ecb-dffd-4310-a138-1e865efb1be3
# ╠═26ea351d-51b1-4f0d-a0c9-a829fcbcd8c4
# ╠═e0b364bc-1bf2-4e4a-a9cf-aa84cf8e12ef
# ╠═d8da6f71-b414-4619-aa4a-1b9fb1a16df3
# ╠═07f5031a-d1c1-4de9-ad54-9f49b57a8304
# ╠═e3b532d5-2ff1-49df-9e2d-7e204ad35856
# ╠═a1a7a7e7-ab61-4ecb-b59f-e367202b0d6d
# ╠═cbf60840-f8c3-456b-ac1e-b99603dac13e
# ╠═3f40b150-98c9-4bb9-9846-668fc30ff401
# ╠═6c10f679-1482-4deb-9665-7ece6e6380de
# ╠═4267d684-d727-4446-8b4f-25836aa3babf
# ╠═b44ec80a-0d9d-4544-b341-15231e0f8293
