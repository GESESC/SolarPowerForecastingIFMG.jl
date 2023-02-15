### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 1bafeb38-ad56-11ed-2109-2db2ca454b57
md"""
# TCC - Victor Gonçalves
## Descrição da Proposta e Ferramentas
Autor: Prof. Dr. Reginaldo Gonçalves Leão Junior

A corrente proposta do trabalho consiste no uso de uma rede neural recorrente (RNN) com camadas do tipo *long short-term memory* para predição da potência solar na microrregião de Formiga ou na Mesorregião Oeste de Minas Gerais. Os dados de treinamento do modelo devem ser obtidos de *datasets* gratuítos disponibilizados na web e os dados climáticos da região obtidos do INMET.(https://portal.inmet.gov.br/dadoshistoricos).

Por motivos de desempenho, o modelo será desenvolvido na linguagem Julia (+1.7 - https://julialang.org/downloads/) utilizando a biblioteca Flux.jl (https://fluxml.ai/Flux.jl/stable/) para a implementação das soluções baseadas em ML. Todas as funcionalidades estão contidas em um módulo denominado `SolarPowerForecastingIFMG` desenvolvido no contexto deste trabalho de conclusão de curso.

A rotina de uso do modelo deve seguir a seguinte rotina, obviamente, flexibilizações podem ser introduzidas quando necessário, ou mesmo novas rotinas podem ser criadas.
"""

# ╔═╡ Cell order:
# ╠═1bafeb38-ad56-11ed-2109-2db2ca454b57
