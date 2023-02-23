using DataFrames
using SolarPowerForecastingIFMG.RaspagemDeDadosINMET
using Missings
using Dates
using Random
using InlineStrings
"""
Corrige a codificação de nomes de colunas.

Recebe:

i) ser_cid::SerieCidades:
Uma estrutura de captura de dados do INMET do tipo SerieCidades

Retorna:
i) ser_cid:
A estrutura de captura com o nome das colunas pertencentes ao dataset interno
de cada cidade com a codificação de nome modificada. 
"""
function ajst_colnames!(ser_cid::SerieCidades)
    columns_change = (
        3=>"PRECIPITACAO TOTAL, HORARIA (mm)",
        5=>"PRESSAO ATMOSFERICA MAX.NA HORA ANT.(AUT) (mB)",
        6=>"PRESSAO ATMOSFERICA MIN.NA HORA ANT.(AUT) (mB)",
        7=>"RADIACAO GLOBAL (KJ/m²)",
        8=>"TEMPERATURA DO AR - BULBO SECO, HORARIA (°C)",
        9=>"TEMPERATURA DO PONTO DE ORVALHO (°C)",
        10=>"TEMPERATURA MAXIMA NA HORA ANT.(AUT) (°C)",
        11=>"TEMPERATURA MINIMA NA HORA ANT.(AUT) (°C)",
        12=>"TEMPERATURA ORVALHO MAX. NA HORA ANT. (AUT) (°C)",
        13=>"TEMPERATURA ORVALHO MIN. NA HORA ANT. (AUT) (°C)",
        17=>"VENTO, DIRECAO HORARIA (gr) (°(gr))"
    )
    for sr in ser_cid.serie
        for col in columns_change
            rename!(sr.dataset, col)
        end
    end
    #return ser_cid
end

"""
Realiza a truncagem do dataset, dividindo-o em 'train set' e 'validation set' e 
excluindo do dataset principal as features não empregadas pelo modelo.

Recebe:

i) dataset::DataFrame:
Um dataframe extraído do INMET com dados meteorológicos.

ii) opcional - metodo::String = "torres":
Um método de modificação da DataFrame passado como str ing. 
Atualmente apenas o método de torres está disponível, além disso 
ele é assumido como parâmetro padrão, tornando o argumento opcional

iii) opcional - p_trunc::NamedTuple=(tr::Float64 =.7, vd::Float64 =.3):
Uma tupla nomeada com os percentuais de truncagem (tr) e validação (vd). 
.7 e .3 são assumidos como padrão.

"""
function treat_data!(
    sercid::SerieCidades, 
    metodo::Symbol = :torres; 
    tr::Float64 =.7, 
    vd::Float64 =.3
)
    for (i,s) in enumerate(sercid.serie)
        cpy_dataset = copy(s.dataset)
        dataset = DataFrame()
        if metodo == :torres
            # Seleciona as colunas com dados crus raw
            columns_change = Dict(
                01 => :DATE,
                02 => :HORA,
                03 => :ADRAIN,
                07 => :ADSOLPW,
                10 => :DTMAX_C,
                11 => :DTMIN_C
            )
            for col in columns_change
                rename!(cpy_dataset, col)
            end
        
            # Trunca o dataset para contemplar apenas as colunas presentes no
            # dicionário columns_change.
            # problema aqui
            select!(cpy_dataset, collect(values(columns_change)))

            # Lista as datas únicas do dataset
            dates_uniq = unique(select(cpy_dataset, :DATE))

            # Substitui missings por zeros 
            for (id, col) in enumerate(eachcol(cpy_dataset))
                cpy_dataset[:,id] = replace(col, missing => 0.)
            end

            # Rotina para agrupamento de dados diários
            function mod_date(d)
                if typeof(d) == String15
                    d = String(d)
                    if occursin('/', d)
                        d = replace(d, '/'=>'-')
                        return Date(d, dateformat"yyyy-mm-dd")
                    end
                else
                    return d
                end
            end

            for dt in eachrow(dates_uniq)
                void_df = DataFrame()
                df_locday = subset(cpy_dataset, :DATE => day -> day .== dt[:DATE])
                df_locday[!,:DATE] = [
                        mod_date(d) for d in df_locday[!,:DATE]
                ]
                void_df = hcat(
                    void_df,
                    combine(
                        df_locday, 
                        [:ADRAIN, :ADSOLPW] .=> sum, 
                        renamecols=false
                    )
                )
                void_df = hcat(
                    void_df,
                    combine(
                        df_locday, 
                        :DTMAX_C => maximum, 
                        renamecols=false
                    )
                )
                void_df = hcat(
                    void_df,
                    combine(
                        df_locday, 
                        :DTMIN_C => minimum, 
                        renamecols=false
                    )
                )
                void_df = hcat(
                    void_df,
                    combine(
                        df_locday, 
                        :DATE => first, 
                        renamecols=false
                    )
                )
                dataset = vcat(dataset, void_df)
            end
        end
        sercid.serie[i].dataset = dataset
    end
    return sercid
end

"""
Realiza o divisão randômica do dataset em train set e test set.

Recebe:

i) dataset::DataFrame:
Um dataframe extraído do INMET com dados meteorológicos.

ii) opcional - frac::Float64 = 0.7:
A fração aplicada a criação do dataset de treinamento. 
"""
function split_df(dataset; frac=.7)
    ids = collect(axes(dataset, 1))
    shuffle!(ids)
    sel = ids .<= nrow(dataset) .* frac
    return dataset[sel, :], dataset[.!sel, :]
end