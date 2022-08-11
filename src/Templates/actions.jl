using AbInitioSoftwareBase: save, load, extension
using AbInitioSoftwareBase.Inputs: Input, getpseudodir, getpotentials
using ExpressBase: Action, calculation
using Pseudopotentials: download_potential
using SimpleWorkflows: Job

using ..Config: ConfigFile

export DownloadPotentials
export jobify

struct ExpandConfig{T} <: Action{T} end  # To be extended

struct DownloadPotentials{T} <: Action{T} end
function (::DownloadPotentials)(template::Input)
    dir = getpseudodir(template)
    if !isdir(dir)
        mkpath(dir)
    end
    potentials = getpotentials(template)
    return map(potentials) do potential
        path = joinpath(dir, potential)
        if !isfile(path)
            download_potential(potential, path)
        end
    end
end

jobify(x::DownloadPotentials, template::Input) = Job(() -> x(template))
jobify(x::DownloadPotentials, config) = Job(() -> x(config.template))
function jobify(x::DownloadPotentials{T}, file::ConfigFile) where {T}
    raw_config = load(file)
    config = ExpandConfig{T}()(raw_config)
    return jobify(x, config)
end
