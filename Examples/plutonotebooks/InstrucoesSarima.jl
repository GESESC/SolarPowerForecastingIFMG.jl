### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ 8a6d1d20-f17b-11ed-1d3e-392f932ca68b
begin
	using Pkg
	Pkg.activate("/home/reginaldo/Insync/Trabalho/IFMG/IFMG_ARCOS/TCCs/TCCVitinho/SolarPowerForecastingIFMG.jl/Test/dev_env")
end

# ╔═╡ e9523590-c0c0-4b84-9cf5-30e4a144af0d
using StateSpaceModels

# ╔═╡ e7c99347-61af-4b13-9c11-451f183a5b88
using SolarPowerForecastingIFMG.RaspagemDeDadosINMET, SolarPowerForecastingIFMG.TruncagemDeDados, DataFrames

# ╔═╡ 8ed7f635-139b-4cf2-a943-5a602d7621c2
md"""
# TCC - Victor Gonçalves
## Instruções para o Método Arima Sasonal (SARIMA)
Autor: Prof. Dr. Reginaldo Gonçalves Leão Junior
"""

# ╔═╡ 20cd3c7b-b7ea-4a08-8be0-a2837e017375
md"""
Ativação do pacote que disponibiliza os métodos de *forecasting*.

Você deve citar o pacote no texto usando
```
@article{SaavedraBodinSouto2019,
title={StateSpaceModels.jl: a Julia Package for Time-Series Analysis in a State-Space Framework},
author={Raphael Saavedra and Guilherme Bodin and Mario Souto},
journal={arXiv preprint arXiv:1908.01757},
year={2019}
}
```
"""

# ╔═╡ 9e37eb7c-595b-4b82-bbcd-d92b60e22615
md"""
Em seguida faz-se a extração dos dados utilizando a forma convencional.
"""

# ╔═╡ 25e75f75-7eba-4864-a7f5-a4e4096ee488
begin
	fonte_dados = statusINMET();
	dados = obter_dados(fonte_dados, ["FORMIGA"], 2010:2023);
	ajst_colnames!(dados);
	treat_data!(dados);
end

# ╔═╡ a597c3fa-2a50-479b-95fa-2edd3ed95d07


# ╔═╡ Cell order:
# ╠═8ed7f635-139b-4cf2-a943-5a602d7621c2
# ╠═8a6d1d20-f17b-11ed-1d3e-392f932ca68b
# ╠═20cd3c7b-b7ea-4a08-8be0-a2837e017375
# ╠═e9523590-c0c0-4b84-9cf5-30e4a144af0d
# ╠═9e37eb7c-595b-4b82-bbcd-d92b60e22615
# ╠═e7c99347-61af-4b13-9c11-451f183a5b88
# ╠═25e75f75-7eba-4864-a7f5-a4e4096ee488
# ╠═a597c3fa-2a50-479b-95fa-2edd3ed95d07
