import Pkg
Pkg.add("JuMP")
using JuMP
include("robustVariable.jl")
model = Model();


@variable(model, test=10, name="test")