module SolarPowerForecastingIFMG

    module RaspagemDeDadosINMET 
        include("RaspagemDeDadosINMET.jl");
        export EstruturaDeCaptura, SerieCidades, statusINMET, obter_dados
    end

    module TruncagemDeDados
        include("TruncagemDeDados.jl");
        export ajst_colnames!, treat_data!
    end

end # module
