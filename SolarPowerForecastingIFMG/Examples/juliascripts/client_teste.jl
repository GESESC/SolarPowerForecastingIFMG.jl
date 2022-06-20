using SolarPowerForecastingIFMG: statusINMET, obter_dados
fonte_dados = statusINMET();
@show fonte_dados[2000];
@show fonte_dados[2010];
@show fonte_dados[2022];
dados = obter_dados(fonte_dados, ["BELO HORIZONTE", "Formiga"], [2016])