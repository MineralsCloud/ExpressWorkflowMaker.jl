module Config

using Configurations
using Unitful: Unitful, PressureUnits, uparse, @u_str
using UnitfulAtomic: UnitfulAtomic

import Configurations: convert_to_option

export @vopt, vopt

abstract type VectorOption end

convert_to_option(::Type{<:VectorOption}, ::Type{Vector}, str::AbstractString) =
    eval(Meta.parse(str))

Base.size(A::VectorOption) = size(A.values)

Base.getindex(A::VectorOption, I) = getindex(A.values, I) * A.unit

Base.setindex!(A::VectorOption, v, I) = setindex!(A.values, v, I)

macro vopt(type, unit, alias, checkvalues = identity, checkunit = identity)
    return esc(vopt(type, unit, alias, checkvalues, checkunit))
end

function vopt(type, unit, alias, checkvalues = identity, checkunit = identity)
    unit = _uparse(unit)
    utype = typeof(unit)
    return quote
        Config.@option $alias struct $type <: Config.VectorOption
            values::Vector{Float64}
            unit::$utype
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

end
