module SolarPowerForecastingIFMG

    module RaspagemDeDadosINMET 
        include("RaspagemDeDadosINMET.jl");
        export EstruturaDeCaptura, SerieCidades, statusINMET, obter_dados
    end

    module TruncagemDeDados
        include("TruncagemDeDados.jl");
        export ajs_col_names!, trunc_data!
    end

end # module
