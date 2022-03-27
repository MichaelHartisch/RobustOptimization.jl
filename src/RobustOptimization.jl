module RobustOptimization

testfunc() = 0
function get_robust(m::Model)
    if haskey(m.ext, :JuMPeR)
        return m.ext[:JuMPeR]
    end
    error("This functionality is only available for a JuMPeR RobustModel.")
end


include("uncertain.jl")
end
