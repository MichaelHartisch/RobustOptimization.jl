import Pkg
Pkg.add("JuMP")
Pkg.add("HiGHS")
using JuMP
using HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, x1 >= 0, Int)
@variable(model, x2 >= 0, Int)
@objective(model, Max, 83x1 + 140x2)
@constraint(model, const1, 1.13x1 + 1.29x2 <= 7.5)
print(model)
optimize!(model)
@show termination_status(model)
@show primal_status(model)
@show dual_status(model)
@show objective_value(model)
@show value(x1)
@show value(x2)

