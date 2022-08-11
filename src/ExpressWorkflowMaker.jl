module ExpressWorkflowMaker

include("Templates/Templates.jl")

using AbInitioSoftwareBase.Commands: CommandConfig
using Configurations: from_dict, option_m, @option
using Formatting: sprintf1
using Unitful: PressureUnits, VolumeUnits, Units, uparse, @u_str
using Unitful
using UnitfulAtomic

import Configurations: convert_to_option

# export Pressures, Volumes
export @uvec

abstract type UnitfulVector <: AbstractVector{Float64} end

convert_to_option(::Type{<:UnitfulVector}, ::Type{Vector}, str::AbstractString) =
    eval(Meta.parse(str))
convert_to_option(::Type{<:UnitfulVector}, ::Type{VolumeUnits}, str::AbstractString) =
    myuparse(str)

Base.size(A::UnitfulVector) = size(A.values)

Base.getindex(A::UnitfulVector, I) = getindex(A.values, I) * A.unit

Base.setindex!(A::UnitfulVector, v, I) = setindex!(A.values, v, I)

macro uvec(typename, unittype, alias, defaultunit)
    ex = quote
        struct $typename <: UnitfulVector
            values::Vector{Float64}
            unit::$unittype
        end
    end
    ex = quote
        @option $(esc(ex))
        $typename(values, unit::AbstractString=@u_str($defaultunit)) = $typename(collect(values), myuparse(unit))
    end
end

# @option "pressures" struct Pressures <: UnitfulVector
#     values::Vector{Float64}
#     unit::PressureUnits
# end

# @option "volumes" struct Volumes <: UnitfulVector
#     values::Vector{Float64}
#     unit::VolumeUnits
# end
# Volumes(values, unit::AbstractString = u"angstrom^3") = Volumes(collect(values), myuparse(unit))

myuparse(str::AbstractString) =
    uparse(filter(!isspace, str); unit_context=[Unitful, UnitfulAtomic])
myuparse(num::Number) = num  # FIXME: this might be error-prone!

end
