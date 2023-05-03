### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ cbe6aa22-a0bd-4a55-8908-b92ecff92c17
using Pkg

# ╔═╡ 492be1d3-f932-43ca-a283-28db361d90de
# i) Na primeira execução do pacote
Pkg.develop("SolarPowerForecastingIFMG")

# ╔═╡ 71ae5ae8-7828-4c93-a31c-c8694ec9f0d5
using SolarPowerForecastingIFMG: statusINMET, obter_dados

# ╔═╡ e958af86-ef31-11ec-35fd-41699b5ff61a
md"""
# TCC - Victor Gonçalves
## Instruções de uso do código
Autor: Prof. Dr. Reginaldo Gonçalves Leão Junior

### Descrição da Proposta e Ferramentas
A corrente proposta do trabalho consiste no uso de uma rede neural recorrente (RNN) com camadas do tipo *long short-term memory* para predição da potência solar na microrregião de Formiga ou na Mesorregião Oeste de Minas Gerais. Os dados de treinamento do modelo devem ser obtidos de *datasets* gratuítos disponibilizados na web e os dados climáticos da região obtidos do INMET.(https://portal.inmet.gov.br/dadoshistoricos).

Por motivos de desempenho, o modelo será desenvolvido na linguagem Julia (+1.7 - https://julialang.org/downloads/) utilizando a biblioteca Flux.jl (https://fluxml.ai/Flux.jl/stable/) para a implementação das soluções baseadas em ML. Todas as funcionalidades estão contidas em um módulo denominado `SolarPowerForecastingIFMG` desenvolvido no contexto deste trabalho de conclusão de curso.

A rotina de uso do modelo deve seguir a seguinte rotina, obviamente, flexibilizações podem ser introduzidas quando necessário, ou mesmo novas rotinas podem ser criadas.

### Verificação do status INMET

Consiste na chamada à função `statusINMET()` que verifica a disponibilidade de séries anuais climatológicas no recurso `/dadoshistoricos` do portal, exibe um compilado deste estatus no terminal e retorna um dicionário com a estrutura:

```
Dict{Int16, String} with n entries:
  "20XX" => "https://portal.inmet.gov.br/uploads/dadoshistoricos/20XX.zip"
```

no qual as chaves são os anos disponíveis na base no formato de um inteiro de 32 bits e os valores uma String contendo o link para download do zip file das séries para o respectivo ano.

Antes de qualquer verificação, deve-se fazer a instalação do pacote em desenvolvimento, ou verificação por atualizações.
Sendo o primeiro uso do pacote em uma determinada instalção deve-se executar as instruções do comentário `i)`, nas demais, atualizações devem ser checadas por meio das instruções do comentário `ii)`. A instrução `using Pkg` é apenas uma chamada ao módulo `Pkg` responsável pela gerência dos pacotes.
"""

# ╔═╡ 2df71c54-011e-41b3-8b75-2edfb9571d60
# ii) A cada nova adição de funcionalidade
Pkg.update("SolarPowerForecastingIFMG")

# ╔═╡ 7f6ab4b6-99aa-409d-904e-9e30470e6ffe
md"""
Após a instalação ou atualização o pacote deve ser carregado no *kernel* em execução, em seguida a verificação do status no INMET pode ser imediatamente realizada.
"""

# ╔═╡ a716b0fb-1d46-4981-a9b4-09dba80e2a08
fonte_dados = statusINMET();

# ╔═╡ Cell order:
# ╟─e958af86-ef31-11ec-35fd-41699b5ff61a
# ╠═cbe6aa22-a0bd-4a55-8908-b92ecff92c17
# ╠═492be1d3-f932-43ca-a283-28db361d90de
# ╠═2df71c54-011e-41b3-8b75-2edfb9571d60
# ╟─7f6ab4b6-99aa-409d-904e-9e30470e6ffe
# ╠═71ae5ae8-7828-4c93-a31c-c8694ec9f0d5
# ╠═a716b0fb-1d46-4981-a9b4-09dba80e2a08
