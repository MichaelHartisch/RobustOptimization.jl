function JuMP.add_variable(
    model::RobustModel,
    v::RobustVariable,
    name::String = ""
    )

    model.nextvaridx+=1
    print("Index of new Variable will be ",model.nextvaridx ,"\n")

    if typeof(v) == UncertainVariable
        vref = UncertainVariableRef(model, model.nextvaridx, length(model.uncertainVariables)+1,'U')
        model.uncertainVariables[vref.type_variable_index] = v
        model.var_index_to_type_index[model.nextvaridx]=length(model.uncertainVariables)
        model.type_index_to_var_index[length(model.uncertainVariables)]=model.nextvaridx

    elseif typeof(v) == DecisionVariable
        vref = DecisionVariableRef(model, model.nextvaridx, length(model.decisionVariables)+1,'D')
        model.decisionVariables[vref.type_variable_index] = v
        model.var_index_to_type_index[model.nextvaridx]=length(model.decisionVariables)
        model.type_index_to_var_index[length(model.decisionVariables)]=model.nextvaridx
    end
    print("Now Size of uncertainVariables ",length(model.uncertainVariables),"\n")
    print("Now Size of decisionVariables ",length(model.decisionVariables),"\n")
    JuMP.set_name(vref, name)
    #return vref
    return vref
end


function JuMP.build_variable(
    _error::Function,
    info::JuMP.VariableInfo,
    var_type::RobustVariableType;
    extra_kwargs...
    )
    # check for unneeded keywords
    for (kwarg, _) in extra_kwargs
        _error("Keyword argument $kwarg is not for use with infinite variables.")
    end
    # get the parameter_refs
    thisStage = var_type.stage

    #ToDO
    if typeof(var_type) == Uncertain
        return UncertainVariable(info, thisStage)
    elseif typeof(var_type) == Decision
        return DecisionVariable(info, thisStage)
    else
        _error("Weird Variable Type!")
    end
end


function Base.:(==)(v::RobustVariableRef, w::RobustVariableRef)
    return v.model === w.model && v.idx == w.idx
end

Base.broadcastable(v::RobustVariableRef) = Ref(v)
JuMP.isequal_canonical(v::RobustVariableRef, w::RobustVariableRef) = v == w

function JuMP.delete(model::RobustModel, vref::RobustVariableRef)
    @assert JuMP.is_valid(model, vref)
    if typeof(vref) == UncertainVariableRef
        delete!(model.uncertainVariables, vref.type_variable_index)
    elseif typeof(vref) == DecisionVariableRef
        delete!(model.decisionVariables, vref.type_variable_index)
    end
    return delete!(model.var_to_name, vref.variable_index)
end




function JuMP.delete(model::RobustModel, vrefs::Vector{RobustVariableRef})
    return JuMP.delete.(model, vrefs)
end
function JuMP.is_valid(model::RobustModel, vref::RobustVariableRef)
    if typeof(vref) == UncertainVariableRef
        return (model === vref.model && vref.type_variable_index in keys(model.uncertainVariables))
    else
        return (model === vref.model && vref.type_variable_index in keys(model.decisionVariables))
    end
end


variable_info(vref::UncertainVariableRef) = vref.model.uncertainVariables[vref.type_variable_index].info
variable_info(vref::DecisionVariableRef) = vref.model.decisionVariables[vref.type_variable_index].info

function update_variable_info(vref::RobustVariableRef, info::JuMP.VariableInfo)
    if typeof(vref) == UncertainVariableRef
        return vref.model.uncertainVariables[vref.type_variable_index] = JuMP.ScalarVariable(info)
    else
        return vref.model.decisionVariables[vref.type_variable_index] = JuMP.ScalarVariable(info)
    end
end

JuMP.has_lower_bound(vref::RobustVariableRef) = variable_info(vref).has_lb

function JuMP.lower_bound(vref::RobustVariableRef)::Float64
    @assert !JuMP.is_fixed(vref)
    return variable_info(vref).lower_bound
end

function JuMP.set_lower_bound(vref::RobustVariableRef, lower)
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

function JuMP.delete_lower_bound(vref::RobustVariableRef)
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

JuMP.has_upper_bound(vref::RobustVariableRef) = variable_info(vref).has_ub
function JuMP.upper_bound(vref::RobustVariableRef)::Float64
    @assert !JuMP.is_fixed(vref)
    return variable_info(vref).upper_bound
end
function JuMP.set_upper_bound(vref::RobustVariableRef, upper)
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
function JuMP.delete_upper_bound(vref::RobustVariableRef)
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

JuMP.is_fixed(vref::RobustVariableRef) = variable_info(vref).has_fix
function JuMP.fix_value(vref::RobustVariableRef)::Float64
    return variable_info(vref).fixed_value
end
function JuMP.fix(vref::RobustVariableRef, value; force::Bool = false)
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
function JuMP.unfix(vref::RobustVariableRef)
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
function JuMP.start_value(vref::RobustVariableRef)::Union{Nothing,Float64}
    return variable_info(vref).start
end
function JuMP.set_start_value(vref::RobustVariableRef, start)
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
JuMP.is_binary(vref::RobustVariableRef) = variable_info(vref).binary
function JuMP.set_binary(vref::RobustVariableRef)
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
function JuMP.unset_binary(vref::RobustVariableRef)
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
JuMP.is_integer(vref::RobustVariableRef) = variable_info(vref).integer
function JuMP.set_integer(vref::RobustVariableRef)
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
function JuMP.unset_integer(vref::RobustVariableRef)
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
