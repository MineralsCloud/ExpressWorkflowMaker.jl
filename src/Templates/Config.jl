module Config

using Configurations: OptionField, @option
using Unitful: Unitful, FreeUnits, Quantity, uparse, dimension
using UnitfulAtomic: UnitfulAtomic

import Configurations: from_dict

export @vopt, vopt

abstract type VectorOption end

macro vopt(type, unit, alias, checkvalues = identity, checkunit = identity)
    return esc(vopt(type, unit, alias, checkvalues, checkunit))
end

function vopt(type, unit, alias, checkvalues = identity, checkunit = identity)
    unit = _uparse(unit)
    return quote
        Config.@option $alias struct $type <: Config.VectorOption
            values::Vector{Float64}
            unit::Config.FreeUnits
            function $type(values, unit = $unit)
                $checkvalues(values)
                $checkunit(unit)
                return new(values, unit)
            end
        end
    end
end

_uparse(str::AbstractString) =
    uparse(filter(!isspace, str); unit_context = [Unitful, UnitfulAtomic])

from_dict(
    ::Type{<:VectorOption},
    ::OptionField{:values},
    ::Type{Vector{Float64}},
    str::AbstractString,
) = eval(Meta.parse(str))
from_dict(
    ::Type{<:VectorOption},
    ::OptionField{:unit},
    ::Type{<:FreeUnits},
    str::AbstractString,
) = _uparse(str)

# Similar to https://github.com/JuliaCollections/IterTools.jl/blob/0ecaa88/src/IterTools.jl#L1028-L1032
function Base.iterate(iter::VectorOption, state = 1)
    if state > length(iter.values)
        return nothing
    else
        return getindex(iter.values, state) * iter.unit, state + 1
    end
end

Base.eltype(iter::VectorOption) = Quantity{Float64,dimension(iter.unit),typeof(iter.unit)}

Base.length(iter::VectorOption) = length(iter.values)

Base.size(iter::VectorOption) = size(iter.values)

end
