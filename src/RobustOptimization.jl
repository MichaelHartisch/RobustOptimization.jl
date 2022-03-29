module RobustOptimization
import Pkg
Pkg.add("JuMP")
Pkg.add("HiGHS")
using JuMP
using HiGHS
testfunc() = 0
function get_robust(m::Model)
    m.ext:JuMPeR
    #print(m.ext[:JuMPeR])
    print("EXT: ",m.ext)
    #if haskey(m.ext, :JuMPeR)
    #    return m.ext[:JuMPeR]
    #end
    #error("This functionality is only available for a JuMPeR RobustModel.")
end
m = Model()
get_robust(m)
include("uncertain.jl")
end
