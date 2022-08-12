module Config

using Configurations: OptionField, @option
using Unitful: Unitful, FreeUnits, uparse
using UnitfulAtomic: UnitfulAtomic

import Configurations: from_dict

export @vopt, vopt

abstract type VectorOption <: AbstractVector{Float64} end

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
end
