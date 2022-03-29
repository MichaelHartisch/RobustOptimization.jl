# Objective
function JuMP.set_objective_function(m::RobustModel, f::JuMP.AbstractJuMPScalar)
    return m.uncertain_objective_function = f
end
function JuMP.set_objective_function(m::RobustModel, f::Real)
    return m.uncertain_objective_function = JuMP.GenericAffExpr{Float64,UncertainVariableRef}(f)
end
JuMP.objective_sense(model::RobustModel) = model.objectivesense
function JuMP.set_objective_sense(model::RobustModel, sense)
    return model.objectivesense = sense
end
JuMP.objective_function_type(model::RobustModel) = typeof(model.uncertain_objective_function)
JuMP.objective_function(model::RobustModel) = model.uncertain_objective_function
function JuMP.objective_function(model::RobustModel, FT::Type)
    # InexactError should be thrown, this is needed in `objective.jl`
    if !(model.uncertain_objective_function isa FT)
        throw(
            InexactError(
                :objective_function,
                FT,
                typeof(model.uncertain_objective_function),
            ),
        )
    end
    return model.uncertain_objective_function::FT
end

