using Pkg
Pkg.activate(".")

using Revise, Test

# Load a sample module
include("sample-module/SampleModule.jl")

using BlindBake

@testset "Test `invokeMethodsOfModule`" begin
    BlindBake.invokeMethodsOfModule(SampleModule.Controller
                                    ;excludeMethods = [:function1])
end

# TODO: Add tests for all functions
