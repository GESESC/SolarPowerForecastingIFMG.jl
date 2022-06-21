using SolarPowerForecastingIFMG: statusINMET, obter_dados
fonte_dados = statusINMET();
dados = obter_dados(
    fonte_dados, ["Formiga"], 
    2010:2014
);