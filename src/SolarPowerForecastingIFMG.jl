module SolarPowerForecastingIFMG

    module RaspagemDeDadosINMET 
        include("RaspagemDeDadosINMET.jl");
        export EstruturaDeCaptura, SerieCidades, statusINMET, obter_dados
    end

    module TruncagemDeDados
        include("TruncagemDeDados.jl");
        export ajst_colnames!, treat_data!, split_df
    end

end # module
