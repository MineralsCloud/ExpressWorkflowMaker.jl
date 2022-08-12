module Config

using Configurations: OptionField, option_m
using Unitful: Unitful, FreeUnits, Quantity, uparse, dimension
using UnitfulAtomic: UnitfulAtomic

import Configurations: from_dict

export @vopt

abstract type VectorWithUnitOption end

# See https://github.com/Roger-luo/Configurations.jl/blob/933fd46/src/codegen.jl#L82-L84
macro vopt(type, unit, alias, checkvalues = identity, checkunit = identity)
    unit = _uparse(unit)
    ex = :(struct $type <: $VectorWithUnitOption
        values::Vector{Float64}
        unit::$FreeUnits
        function $type(values, unit = $unit)
            $checkvalues(values)
            $checkunit(unit)
            return new(values, unit)
        end
    end)
    return esc(option_m(__module__, ex, alias))
end

_uparse(str::AbstractString) =
    uparse(filter(!isspace, str); unit_context = [Unitful, UnitfulAtomic])

from_dict(
    ::Type{<:VectorWithUnitOption},
    ::OptionField{:values},
    ::Type{Vector{Float64}},
    str::AbstractString,
) = eval(Meta.parse(str))
from_dict(
    ::Type{<:VectorWithUnitOption},
    ::OptionField{:unit},
    ::Type{<:FreeUnits},
    str::AbstractString,
) = _uparse(str)

# Similar to https://github.com/JuliaCollections/IterTools.jl/blob/0ecaa88/src/IterTools.jl#L1028-L1032
function Base.iterate(iter::VectorWithUnitOption, state = 1)
    if state > length(iter.values)
        return nothing
    else
        return getindex(iter.values, state) * iter.unit, state + 1
    end
end

Base.eltype(iter::VectorWithUnitOption) =
    Quantity{Float64,dimension(iter.unit),typeof(iter.unit)}

Base.length(iter::VectorWithUnitOption) = length(iter.values)

Base.size(iter::VectorWithUnitOption) = size(iter.values)

end
