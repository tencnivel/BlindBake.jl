module SampleModule
    module Model
        export AppUser
        include("model/AppUser.jl")
    end

    module Controller
        using Dates
        using ..Model
        include("controller/Controller.jl")
    end

end
