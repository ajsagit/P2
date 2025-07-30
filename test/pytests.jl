import Pkg; Pkg.activate(joinpath(@__DIR__,"devenv"))
#====================================================================================================
       pytests.jl

These are unit tests utilizing Python dependencies.  These do not run in CI/CD but should
be run locally to ensure Parquet2 output is correct.

Should be runnable after instantiating the environment in `devenv`
====================================================================================================#

using Parquet2: Dataset, writefile

include("genparquet.jl")
include("utils.jl")

if isdefined(@__MODULE__, :Revise)
    Revise.track("genparquet.jl")
    Revise.track("utils.jl")
end


@testset "pyarrow" begin
    # want to ensure we test tables of different sizes
    py_compare_pyarrow(standard_test_table(555))
    for _ ∈ 1:3
        py_compare_pyarrow(random_test_table())
    end
end

@testset "fastparquet" begin
    py_compare_fastparquet(standard_test_table(555))
    for _ ∈ 1:3
        py_compare_fastparquet(random_test_table())
    end
end
