"""
ToDos, or already done? See JuMP/src/print.jl

In order for _print_summary(io::IO, model::AbstractModel) to work we need:
* `name(::AbstractModel)`
* `show_objective_function_summary`
* `show_constraints_summary`
* `show_backend_summary`

In order for _print_model(io::IO, model::AbstractModel) to work we need:
* `objective_function_string`
* `constraints_string`
* `_nl_subexpression_string`

In order for _print_latex(io::IO, model::AbstractModel) to work we need:
* `objective_function_string`
* `constraints_string`
* `_nl_subexpression_string`
"""


"""
    show_backend_summary(io::IO, model::Model)

Print a summary of the optimizer backing `model`.

`AbstractModel`s should implement this method.
"""
#function show_backend_summary(io::IO, model::Model)
#    model_mode = mode(model)
#    println(io, "Model mode: ", model_mode)
#    if model_mode == MANUAL || model_mode == AUTOMATIC
#        println(io, "CachingOptimizer state: ", MOIU.state(backend(model)))
#    end
#    # The last print shouldn't have a new line
#    print(io, "Solver name: ", solver_name(model))
#    return
#end



function JuMP.constraint_string(print_mode,
    con::AbstractConstraint;
    in_math_mode = false
    )::String
    func_str = function_string(print_mode,con.func)
    in_set_str = in_set_string(print_mode,con.set)
    return func_str * " " * in_set_str
end

function JuMP.constraints_string(print_mode, model::RobustModel)
    strings = String[]
    # Sort by creation order, i.e. Int value
    uncertainConstraints = sort(collect(model.uncertainConstraints), by = c -> c.first)
    print(uncertainConstraints)
    for (index, constraint) in uncertainConstraints
        push!(strings, JuMP.constraint_string(print_mode, constraint))
    end
    uncertaintySetConstraints = sort(collect(model.uncertaintySetConstraints), by = c -> c.first)
    print(uncertaintySetConstraints)
    for (index, constraint) in uncertaintySetConstraints
        push!(strings, JuMP.constraint_string(print_mode, constraint))
    end
    return strings
end


"""
    show_constraints_summary(io::IO, model::RobustModel)

Write to `io` a summary of the number of constraints.
"""
function JuMP.show_constraints_summary(io::IO, model::RobustModel)
    n = length(model.uncertainConstraints)
    return print(io, "Constraint", _plural(n), ": ", n)

    n_us = length(model.uncertainConstraints)
    return print(io, "Uncertainty Set Constraint", _plural(n_us), ": ", n_us)
end
