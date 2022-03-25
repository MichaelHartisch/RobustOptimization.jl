import Pkg
Pkg.add("JuMP")
Pkg.add("HiGHS")

#Szenarios
scenarios = []
lower = 5
upper = 15
for i in 1:10 
    scenarioItem = rand(Float64)*(upper-lower) + lower
    append!(scenarios,scenarioItem)
end
print(scenarios)

using JuMP
using HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, x >= 0)
@variable(model, 0 <= y <= 3)
@objective(model, Min, 12x + 20y)
for (index,value) in enumerate(scenarios)
    @constraint(model, "c"+index, value*x + 12y >= 120)
end
@constraint(model, c17, 6x + 8y >= 100)

print(model)
optimize!(model)
@show termination_status(model)
@show primal_status(model)
@show dual_status(model)
@show objective_value(model)
@show value(x)
@show value(y)
@show shadow_price(c1)
@show shadow_price(c2)