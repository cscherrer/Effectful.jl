using Effects
using Documenter

DocMeta.setdocmeta!(Effects, :DocTestSetup, :(using Effects); recursive=true)

makedocs(;
    modules=[Effects],
    authors="Chad Scherrer <chad.scherrer@gmail.com> and contributors",
    repo="https://github.com/cscherrer/Effects.jl/blob/{commit}{path}#{line}",
    sitename="Effects.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cscherrer.github.io/Effects.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/cscherrer/Effects.jl",
    devbranch="main",
)
