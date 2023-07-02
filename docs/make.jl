using Effectful
using Documenter

DocMeta.setdocmeta!(Effectful, :DocTestSetup, :(using Effectful); recursive=true)

makedocs(;
    modules=[Effectful],
    authors="Chad Scherrer <chad.scherrer@gmail.com> and contributors",
    repo="https://github.com/cscherrer/Effectful.jl/blob/{commit}{path}#{line}",
    sitename="Effectful.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cscherrer.github.io/Effectful.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/cscherrer/Effectful.jl",
    devbranch="main",
)
