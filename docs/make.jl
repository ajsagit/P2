using Parquet2
using Documenter

DocMeta.setdocmeta!(Parquet2, :DocTestSetup, :(using Parquet2); recursive=true)

makedocs(;
    modules=[Parquet2],
    authors="Expanding Man <savastio@protonmail.com> and contributors",
    repo="https://gitlab.com/ExpandingMan/Parquet2.jl/blob/{commit}{path}#{line}",
    sitename="Parquet2.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ExpandingMan.gitlab.io/Parquet2.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
        "Developer Documentation" => [
            "internals.md",
            "dev.md",
        ],
        "FAQ" => "faq.md",
    ],
    warnonly=[:missing_docs, :cross_references]
)
