using Pkg
Pkg.activate(".")

using Revise, Test, Distributed

addprocs(1)
@everywhere push!(LOAD_PATH, "/home/vlaugier/CODE/BlindBake.jl/")
@everywhere using BlindBake
# Load a sample module
@everywhere include("test/sample-module/SampleModule.jl")


@testset "Test `invokeMethodsOfModule`" begin
    BlindBake.invokeMethodsOfModule(SampleModule.Controller
                                    ;excludeMethods = [:function1])
end

# TODO: Add tests for all functions
