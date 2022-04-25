module RobustOptimization

using JuMP


struct ConstraintIndex
    value::Int # Index in `model.constraints`
end

mutable struct RobustModel <: JuMP.AbstractModel
    nextvaridx::Int                                 # Next variable index is nextvaridx+1
    decisionVariables::Dict{Int,JuMP.AbstractVariable}
    #adaptiveVariables::Dict{Int,JuMP.AbstractVariable}
    uncertainVariables::Dict{Int,JuMP.AbstractVariable}
    var_index_to_type_index::Dict{Int,Int}
    type_index_to_var_index::Dict{Int,Int}
    var_to_name::Dict{Int,String}                  # Map varidx -> name
    name_to_var::Union{Dict{String,Int},Nothing}  # Map varidx -> name
    decisionConstraints::Dict{ConstraintIndex,JuMP.AbstractConstraint}      # Map conidx -> variable
    uncertainConstraints::Dict{ConstraintIndex,JuMP.AbstractConstraint}      # Map conidx -> variable
    con_to_name::Dict{ConstraintIndex,String}      # Map conidx -> name
    name_to_con::Union{Dict{String,ConstraintIndex},Nothing}                     # Map name -> conidx
    objectivesense::OptimizationSense
    uncertain_objective_function::JuMP.AbstractJuMPScalar
    obj_dict::Dict{Symbol,Any}
    function RobustModel()
        return new(
            0,
            Dict{Int,JuMP.AbstractVariable}(),
            #Dict{Int,JuMP.AbstractVariable}(),
            Dict{Int,JuMP.AbstractVariable}(),
            Dict{Int,Int}(),
            Dict{Int,Int}(),
            Dict{Int,String}(),
            nothing,                        # Variables
            Dict{ConstraintIndex,JuMP.AbstractConstraint}(),
            Dict{ConstraintIndex,JuMP.AbstractConstraint}(),
            Dict{ConstraintIndex,String}(),
            nothing,            # Constraints
            FEASIBILITY_SENSE,
            zero(JuMP.GenericAffExpr{Float64,UncertainVariableRef}),
            Dict{Symbol,Any}(),
        )
    end
end



Base.broadcastable(model::RobustModel) = Ref(model)

JuMP.object_dictionary(model::RobustModel) = model.obj_dict
include("datatypes.jl")
include("uncertain_variables.jl")
include("decision_variables.jl")
include("variable_basics.jl")


# Names
JuMP.name(vref::AbstractVariableRef) = vref.model.var_to_name[vref.variable_index]
function JuMP.set_name(vref::AbstractVariableRef, name::String)
    vref.model.var_to_name[vref.variable_index] = name
    return vref.model.name_to_var = nothing
end
function JuMP.variable_by_name(model::RobustModel, name::String)
    if model.name_to_var === nothing
        # Inspired from MOI/src/Utilities/model.jl
        model.name_to_var = Dict{String,Int}()
        for (var, var_name) in model.var_to_name
            if haskey(model.name_to_var, var_name)
                # -1 is a special value that means this string does not map to
                # a unique variable name.
                model.name_to_var[var_name] = -1
            else
                model.name_to_var[var_name] = var
            end
        end
    end
    index = get(model.name_to_var, name, nothing)
    if index isa Nothing
        return nothing
    elseif index == -1
        error("Multiple variables have the name $name.")
    else
        return UncertainVariableRef(model, index)
    end
end

# Show
function JuMP.show_backend_summary(io::IO, model::RobustModel) end
function JuMP.show_objective_function_summary(io::IO, model::RobustModel)
    return println(
        io,
        "Objective function type: ",
        JuMP.objective_function_type(model),
    )
end
function JuMP.objective_function_string(print_mode, model::RobustModel)
    return JuMP.function_string(print_mode, JuMP.objective_function(model))
end
_plural(n) = (isone(n) ? "" : "s")
function JuMP.show_constraints_summary(io::IO, model::RobustModel)
    n = length(model.uncertainConstraints)
    return print(io, "Constraint", _plural(n), ": ", n)
end
function JuMP.constraints_string(print_mode, model::RobustModel)
    strings = String[]
    # Sort by creation order, i.e. ConstraintIndex value
    uncertainConstraints = sort(collect(model.uncertainConstraints), by = c -> c.first.value)
    for (index, constraint) in uncertainConstraints
        push!(strings, JuMP.constraint_string(print_mode, constraint))
    end
    return strings
end


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

JuMP.num_variables(m::RobustModel) = m.nextvaridx
export RobustModel
end
