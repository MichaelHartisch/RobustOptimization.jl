
struct UncertainVariableRef <: JuMP.AbstractVariableRef
    model::RobustModel # `model` owning the variable
    idx::Int       # Index in `model.variables`
end
Base.copy(v::UncertainVariableRef) = v

function Base.:(==)(v::UncertainVariableRef, w::UncertainVariableRef)
    return v.model === w.model && v.idx == w.idx
end

Base.broadcastable(v::UncertainVariableRef) = Ref(v)
JuMP.isequal_canonical(v::UncertainVariableRef, w::UncertainVariableRef) = v == w
function JuMP.add_variable(
    m::RobustModel,
    v::JuMP.AbstractVariable,
    name::String = "",
)
    m.nextvaridx += 1
    vref = UncertainVariableRef(m, m.nextvaridx)
    m.uncertainVariables[vref.idx] = v
    JuMP.set_name(vref, name)
    return vref
end
function JuMP.add_variable(
    model::RobustModel,
    variable::JuMP.VariableConstrainedOnCreation,
    name::String,
)
    var_ref = JuMP.add_variable(model, variable.scalar_variable, name)
    JuMP.add_constraint(model, JuMP.ScalarConstraint(var_ref, variable.set))
    return var_ref
end
function JuMP.add_variable(
    model::RobustModel,
    variable::JuMP.VariablesConstrainedOnCreation,
    names,
)
    var_refs =
        JuMP.add_variable.(
            model,
            variable.scalar_variables,
            JuMP.vectorize(names, variable.shape),
        )
    JuMP.add_constraint(model, JuMP.VectorConstraint(var_refs, variable.set))
    return JuMP.reshape_vector(var_refs, variable.shape)
end


function JuMP.delete(model::RobustModel, vref::UncertainVariableRef)
    @assert JuMP.is_valid(model, vref)
    delete!(model.uncertainVariables, vref.idx)
    return delete!(model.var_to_name, vref.idx)
end
function JuMP.delete(model::RobustModel, vrefs::Vector{UncertainVariableRef})
    return JuMP.delete.(model, vrefs)
end
function JuMP.is_valid(model::RobustModel, vref::UncertainVariableRef)
    return (model === vref.model && vref.idx in keys(model.uncertainVariables))
end
JuMP.num_variables(m::RobustModel) = length(m.uncertainVariables)

variable_info(vref::UncertainVariableRef) = vref.model.uncertainVariables[vref.idx].info
function update_variable_info(vref::UncertainVariableRef, info::JuMP.VariableInfo)
    return vref.model.uncertainVariables[vref.idx] = JuMP.ScalarVariable(info)
end

JuMP.has_lower_bound(vref::UncertainVariableRef) = variable_info(vref).has_lb
function JuMP.lower_bound(vref::UncertainVariableRef)::Float64
    @assert !JuMP.is_fixed(vref)
    return variable_info(vref).lower_bound
end
function JuMP.set_lower_bound(vref::UncertainVariableRef, lower)
    info = variable_info(vref)
    return update_variable_info(
        vref,
        JuMP.VariableInfo(
            true,
            lower,
            info.has_ub,
            info.upper_bound,
            info.has_fix,
            info.fixed_value,
            info.has_start,
            info.start,
            info.binary,
            info.integer,
        ),
    )
end

function JuMP.delete_lower_bound(vref::UncertainVariableRef)
    info = variable_info(vref)
    return update_variable_info(
        vref,
        JuMP.VariableInfo(
            false,
            info.lower_bound,
            info.has_ub,
            info.upper_bound,
            info.has_fix,
            info.fixed_value,
            info.has_start,
            info.start,
            info.binary,
            info.integer,
        ),
    )
end
JuMP.has_upper_bound(vref::UncertainVariableRef) = variable_info(vref).has_ub
function JuMP.upper_bound(vref::UncertainVariableRef)::Float64
    @assert !JuMP.is_fixed(vref)
    return variable_info(vref).upper_bound
end
function JuMP.set_upper_bound(vref::UncertainVariableRef, upper)
    info = variable_info(vref)
    return update_variable_info(
        vref,
        JuMP.VariableInfo(
            info.has_lb,
            info.lower_bound,
            true,
            upper,
            info.has_fix,
            info.fixed_value,
            info.has_start,
            info.start,
            info.binary,
            info.integer,
        ),
    )
end
function JuMP.delete_upper_bound(vref::UncertainVariableRef)
    info = variable_info(vref)
    return update_variable_info(
        vref,
        JuMP.VariableInfo(
            info.has_lb,
            info.lower_bound,
            false,
            info.upper_bound,
            info.has_fix,
            info.fixed_value,
            info.has_start,
            info.start,
            info.binary,
            info.integer,
        ),
    )
end
JuMP.is_fixed(vref::UncertainVariableRef) = variable_info(vref).has_fix
function JuMP.fix_value(vref::UncertainVariableRef)::Float64
    return variable_info(vref).fixed_value
end
function JuMP.fix(vref::UncertainVariableRef, value; force::Bool = false)
    info = variable_info(vref)
    if !force && (info.has_lb || info.has_ub)
        error(
            "Unable to fix $(vref) to $(value) because it has existing bounds.",
        )
    end
    update_variable_info(
        vref,
        JuMP.VariableInfo(
            false,
            info.lower_bound,
            false,
            info.upper_bound,
            true,
            value,
            info.has_start,
            info.start,
            info.binary,
            info.integer,
        ),
    )
    return
end
function JuMP.unfix(vref::UncertainVariableRef)
    info = variable_info(vref)
    return update_variable_info(
        vref,
        JuMP.VariableInfo(
            info.has_lb,
            info.lower_bound,
            info.has_ub,
            info.upper_bound,
            false,
            info.fixed_value,
            info.has_start,
            info.start,
            info.binary,
            info.integer,
        ),
    )
end
function JuMP.start_value(vref::UncertainVariableRef)::Union{Nothing,Float64}
    return variable_info(vref).start
end
function JuMP.set_start_value(vref::UncertainVariableRef, start)
    info = variable_info(vref)
    return update_variable_info(
        vref,
        JuMP.VariableInfo(
            info.has_lb,
            info.lower_bound,
            info.has_ub,
            info.upper_bound,
            info.has_fix,
            info.fixed_value,
            true,
            start,
            info.binary,
            info.integer,
        ),
    )
end
JuMP.is_binary(vref::UncertainVariableRef) = variable_info(vref).binary
function JuMP.set_binary(vref::UncertainVariableRef)
    @assert !JuMP.is_integer(vref)
    info = variable_info(vref)
    return update_variable_info(
        vref,
        JuMP.VariableInfo(
            info.has_lb,
            info.lower_bound,
            info.has_ub,
            info.upper_bound,
            info.has_fix,
            info.fixed_value,
            info.has_start,
            info.start,
            true,
            info.integer,
        ),
    )
end
function JuMP.unset_binary(vref::UncertainVariableRef)
    info = variable_info(vref)
    return update_variable_info(
        vref,
        JuMP.VariableInfo(
            info.has_lb,
            info.lower_bound,
            info.has_ub,
            info.upper_bound,
            info.has_fix,
            info.fixed_value,
            info.has_start,
            info.start,
            false,
            info.integer,
        ),
    )
end
JuMP.is_integer(vref::UncertainVariableRef) = variable_info(vref).integer
function JuMP.set_integer(vref::UncertainVariableRef)
    @assert !JuMP.is_binary(vref)
    info = variable_info(vref)
    return update_variable_info(
        vref,
        JuMP.VariableInfo(
            info.has_lb,
            info.lower_bound,
            info.has_ub,
            info.upper_bound,
            info.has_fix,
            info.fixed_value,
            info.has_start,
            info.start,
            info.binary,
            true,
        ),
    )
end
function JuMP.unset_integer(vref::UncertainVariableRef)
    info = variable_info(vref)
    return update_variable_info(
        vref,
        JuMP.VariableInfo(
            info.has_lb,
            info.lower_bound,
            info.has_ub,
            info.upper_bound,
            info.has_fix,
            info.fixed_value,
            info.has_start,
            info.start,
            info.binary,
            false,
        ),
    )
end



