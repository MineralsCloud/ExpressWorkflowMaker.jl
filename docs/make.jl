using ExpressWorkflowMaker
using Documenter

DocMeta.setdocmeta!(ExpressWorkflowMaker, :DocTestSetup, :(using ExpressWorkflowMaker); recursive=true)

makedocs(;
    modules=[ExpressWorkflowMaker],
    authors="singularitti <singularitti@outlook.com> and contributors",
    repo="https://github.com/MineralsCloud/ExpressWorkflowMaker.jl/blob/{commit}{path}#{line}",
    sitename="ExpressWorkflowMaker.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://MineralsCloud.github.io/ExpressWorkflowMaker.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/MineralsCloud/ExpressWorkflowMaker.jl",
    devbranch="main",
)
