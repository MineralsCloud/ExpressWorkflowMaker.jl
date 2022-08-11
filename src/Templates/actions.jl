using AbInitioSoftwareBase: save, load, extension
using AbInitioSoftwareBase.Inputs: Input, getpseudodir, getpotentials
using Pseudopotentials: download_potential

using ExpressBase: Action, calculation

struct DownloadPotentials{T} <: Action{T} end
function (x::DownloadPotentials)(template::Input)
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
