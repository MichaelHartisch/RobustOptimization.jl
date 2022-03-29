module RobustOptimization

using JuMP

struct ConstraintIndex
    value::Int # Index in `model.constraints`
end
mutable struct RobustModel <: JuMP.AbstractModel
    nextvaridx::Int                                 # Next variable index is nextvaridx+1
    uncertainVariables::Dict{Int,JuMP.ScalarVariable}       # Map varidx -> variable
    var_to_name::Dict{Int,String}                  # Map varidx -> name
    name_to_var::Union{Dict{String,Int},Nothing}  # Map varidx -> name
    nextconidx::Int                                 # Next constraint index is nextconidx+1
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
            Dict{Int,String}(),
            nothing,                        # Variables
            0,
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
include("uncertain.jl")

include("uncertainConstraints.jl")
include("uncertainObjectiveFunction.jl")

# Names
JuMP.name(vref::UncertainVariableRef) = vref.model.var_to_name[vref.idx]
function JuMP.set_name(vref::UncertainVariableRef, name::String)
    vref.model.var_to_name[vref.idx] = name
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
JuMP.name(cref::UncertainConstraintRef) = cref.model.con_to_name[cref.index]
function JuMP.set_name(cref::UncertainConstraintRef, name::String)
    cref.model.con_to_name[cref.index] = name
    return cref.model.name_to_con = nothing
end
function JuMP.constraint_by_name(model::RobustModel, name::String)
    if model.name_to_con === nothing
        # Inspired from MOI/src/Utilities/model.jl
        model.name_to_con = Dict{String,ConstraintIndex}()
        for (con, con_name) in model.con_to_name
            if haskey(model.name_to_con, con_name)
                # -1 is a special value that means this string does not map to
                # a unique constraint name.
                model.name_to_con[con_name] = ConstraintIndex(-1)
            else
                model.name_to_con[con_name] = con
            end
        end
    end
    index = get(model.name_to_con, name, nothing)
    if index isa Nothing
        return nothing
    elseif index.value == -1
        error("Multiple constraints have the name $name.")
    else
        # We have no information on whether this is a vector constraint
        # or a scalar constraint
        return JuMP.ConstraintRef(model, index, JuMP.ScalarShape())
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




testfunc() = 0
end
