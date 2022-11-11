using DataFrames
using SolarPowerForecastingIFMG.RaspagemDeDadosINMET
using Missings

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
function ajs_col_names!(ser_cid::SerieCidades)
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
function trunc_data!(
    dataset::DataFrame, 
    metodo::Symbol = :torres; 
    tr::Float64 =.7, 
    vd::Float64 =.3
)
    if metodo == :torres
        columns_change = Dict(
            01 => :DATE,
            02 => :HORA,
            03 => :ADRAIN,
            07 => :ADSOLPW,
            10 => :DTMAX_C,
            11 => :DTMIN_C
        )
        for col in columns_change
            rename!(dataset, col)
        end
        
        # Trunca o dataset para contemplar apenas as colunas presentes no
        # dicionário columns_change.
        # problema aqui
        select!(dataset, collect(values(columns_change)))

        # Lista as datas únicas do dataset
        dates_uniq = unique(select(dataset, :DATE))

        
        for col in values(columns_change)
            dataset[:,col] = collect(
                Missings.replace(
                    dados.serie[1].dataset[:,:ADSOLPW], 0
                )
            )
        end
        #índice superior e inferior para truncagem 
        #sidx_to_trunc = findfirst(x::Float64->x>0, dataset[:,:ADSOLPW])
        #iidx_to_trunc = findlast(x::Float64->x>0, dataset[:,:ADSOLPW])
        #dataset = dataset[sidx_to_trunc:iidx_to_trunc, :]
    end
    return dataset
end
