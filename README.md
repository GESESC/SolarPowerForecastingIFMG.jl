# SolarPowerForecastingIFMG.jl
## Uma ferramenta para previsão de potência de geração solar baseada em séries históricas

### Autores:
1. Victor Gonçalves (Graduando)
2. Prof. José Antônio (Orientador)
3. Prof. Reginaldo Leão (Coorientador)

O módulo **SolarPowerForecastingIFMG.jl** é uma ferramenta de acesso de alto nível à funcionalidades de previsão de potência solar no Brasil. Ela se baseia em redes neurais recorrentes (RNNs) com camadas do tipo *Long Short-Term Memory* disponibilizadas pelo pacote Flux.jl. 

O pacote ainda possui funcionalidades de alto nível para o tratamento das tabelas CSV do Instituto Nacional de Metrologia (INMET) e raspagem direta dos dados via requisições HTTP com o HTTP.jl, Gumbo.jl e Cascadia.jl. 