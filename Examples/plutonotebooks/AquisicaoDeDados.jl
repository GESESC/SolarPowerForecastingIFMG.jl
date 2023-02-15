### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 43180b6c-96cd-4575-ae31-8a0a30b161ee
# i) Na primeira execução do pacote
begin
	using Pkg
	Pkg.add(url="https://github.com/GESESC/SolarPowerForecastingIFMG.jl")
	Pkg.add("PlutoUI")
end

# ╔═╡ 74dc1203-63c8-4c2a-9718-ccb74f0d3f5e
using SolarPowerForecastingIFMG.RaspagemDeDadosINMET, SolarPowerForecastingIFMG.TruncagemDeDados, DataFrames, Missings, PlutoUI

# ╔═╡ 4dfb5000-ad56-11ed-2793-07029cb1fd07
md"""
# TCC - Victor Gonçalves
## Instruções de obtenção de dados
Autor: Prof. Dr. Reginaldo Gonçalves Leão Junior


### Verificação do status INMET

Consiste na chamada à função `statusINMET()` que verifica a disponibilidade de séries anuais climatológicas no recurso `/dadoshistoricos` do portal, exibe um compilado deste estatus no terminal e retorna um dicionário com a estrutura:

```
Dict{Int16, String} with n entries:
  "20XX" => "https://portal.inmet.gov.br/uploads/dadoshistoricos/20XX.zip"
```

no qual as chaves são os anos disponíveis na base no formato de um inteiro de 32 bits e os valores uma String contendo o link para download do zip file das séries para o respectivo ano.
"""

# ╔═╡ 8ce37dc2-a9f2-4d28-9803-1cf641017f18
md"""
Antes de qualquer verificação, deve-se fazer a instalação do pacote em desenvolvimento, ou verificação por atualizações.
Sendo o primeiro uso do pacote em uma determinada instalação deve-se executar as instruções do comentário `i)`, nas demais, atualizações devem ser checadas por meio das instruções do comentário `ii)`. A instrução `using Pkg` é apenas uma chamada ao módulo `Pkg` responsável pela gerência dos pacotes.
"""

# ╔═╡ 902b43f5-8803-409f-b1bb-3d7211c4e55b
# ii) A cada nova adição de funcionalidade
#using Pkg
#Pkg.update("SolarPowerForecastingIFMG")

# ╔═╡ 630a6ab9-c936-425d-8d62-2cd990f226b0
md"""
Opcionalmente o repositório [SolarPowerForecastingIFMG.jl](https://github.com/GESESC/SolarPowerForecastingIFMG.jl) possui no diretório `Test` o subdiretório `dev_env` onde as configurações para a execução já estão pré-configuradas nos arquivos `Project.toml` e `Manifest.toml` para saber mais sobre essas configurações consulto a seção [*Project environments*](https://docs.julialang.org/en/v1/manual/code-loading/#Project-environments) na documentação da linguagem.

Após a instalação ou atualização o pacote deve ser carregado no *kernel* em execução, em seguida a verificação do status no INMET pode ser imediatamente realizada.
"""

# ╔═╡ 4b0c3a7b-5649-4c13-bfe7-e713d3b4d1df
md"""
O processo de raspagem dos dados no INMET se dá primeiramente pela obtenção de um espelho do site de dados e extração das informações para download dos dados. Tudo isso é feito de forma automatizada por meio do método `statusINMET()`.
"""

# ╔═╡ 4b5131e6-1226-4eb8-9407-f4f1d9b85630
fonte_dados = statusINMET();

# ╔═╡ 097341e9-759a-46a2-a823-9ac618af158e
md"""
Após a execução a variável `fonte_dados` é um dicionário que contém os links para a obtenção das tabelas CSV de cada ano.
"""

# ╔═╡ 06367819-0e34-4d0c-b838-ca1394fd83fc
@show fonte_dados[2000];

# ╔═╡ b46819c9-7e21-46bb-a974-f199fcf45d39
@show fonte_dados[2010];

# ╔═╡ 15063db5-8983-4614-b699-e94974ee4def
@show fonte_dados[2022];

# ╔═╡ 4c6568e7-a80b-4ddd-b7e8-4181fe486b4a
md"""
### Raspagem de Dados
A extração de dados em si se dá por meio da função `obter_dados` cuja documentação pode ser consultada na ferramenta *Live Docs* (verifique o botão na parte inferior direita deste notbook).
"""

# ╔═╡ 9940d90a-7a9d-467f-8062-ccf04a066029
obter_dados

# ╔═╡ f5bfad1b-d8d0-47a8-ac95-ce84ef05ba98


# ╔═╡ Cell order:
# ╟─4dfb5000-ad56-11ed-2793-07029cb1fd07
# ╟─8ce37dc2-a9f2-4d28-9803-1cf641017f18
# ╠═43180b6c-96cd-4575-ae31-8a0a30b161ee
# ╠═902b43f5-8803-409f-b1bb-3d7211c4e55b
# ╟─630a6ab9-c936-425d-8d62-2cd990f226b0
# ╠═74dc1203-63c8-4c2a-9718-ccb74f0d3f5e
# ╟─4b0c3a7b-5649-4c13-bfe7-e713d3b4d1df
# ╠═4b5131e6-1226-4eb8-9407-f4f1d9b85630
# ╟─097341e9-759a-46a2-a823-9ac618af158e
# ╠═06367819-0e34-4d0c-b838-ca1394fd83fc
# ╠═b46819c9-7e21-46bb-a974-f199fcf45d39
# ╠═15063db5-8983-4614-b699-e94974ee4def
# ╠═4c6568e7-a80b-4ddd-b7e8-4181fe486b4a
# ╠═9940d90a-7a9d-467f-8062-ccf04a066029
# ╠═f5bfad1b-d8d0-47a8-ac95-ce84ef05ba98
