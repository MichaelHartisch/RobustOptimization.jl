JuMP.owner_model(cref::RobustConstraintRef)::RobustModel = cref.model

JuMP.index(cref::RobustConstraintRef)::RobustConstraintIndex = cref.index
function Base.:(==)(v::RobustConstraintRef, w::RobustConstraintRef)::Bool
    return v.model === w.model && v.index == w.index
end
Base.broadcastable(cref::RobustConstraintRef) = Ref(cref)

function JuMP.build_constraint(
    _error::Function,
    fun::GenericAffExpr,
    set::MOI.AbstractScalarSet,
    con_type::RobustConstraintType;
    extra_kwargs...
)
    
    print("buildConst","\n")
    if typeof(con_type) == UncertaintySetConstraint
        return UncertaintySetConst(con_type.name,fun,set)
    elseif typeof(con_type) == UncertainConstraint
        return UncertainConst(con_type.name,fun,set)
    else
        _error("Weird Constraint Type!")
    end
end

function JuMP.add_constraint(
    model::RobustModel,
    con::RobustConstraint,
    name::String,
)

    print("addConst","\n")
    model.nextconidx+=1
    if  occursin("UncertaintySetConst",string(typeof(con)))
        cref = UncertaintySetConstraintRef(model,model.nextconidx,length(model.uncertaintySetConstraints)+1,'S')
        model.uncertaintySetConstraints[cref.type_idx] = con
        model.con_index_to_type_index[model.nextconidx] = length(model.uncertaintySetConstraints)
        model.type_index_to_con_index[length(model.uncertaintySetConstraints)]= model.nextconidx
    elseif occursin("UncertainConst", string(typeof(con)))
        cref = UncertainConstraintRef(model,model.nextconidx,length(model.uncertainConstraints)+1,'U')
        model.uncertainConstraints[cref.type_idx] = con
        model.con_index_to_type_index[model.nextconidx] = length(model.uncertainConstraints)
        model.type_index_to_con_index[length(model.uncertainConstraints)]= model.nextconidx
    end
    JuMP.set_name(cref,name)
    return cref
end


#function set_lhs(
#    model::RobustModel,
#    constRef::RobustConstraintRef,
#    value::string,
#    )
#    model.uncertainConstraints[constRef.type_idx].func = value
#end
function lhs(model::RobustModel,
    constRef::RobustConstraintRef,
    )
    return model.uncertainConstraints[constRef.type_idx].func
end
function uncConstant(model::RobustModel,
    constRef::RobustConstraintRef,
    )
    return model.uncertainConstraints[constRef.type_idx].func.constant
end
function uncConstVarCoeff(model::RobustModel,
    constRef::RobustConstraintRef,
    varRef::RobustVariableRef,
    )
    return model.uncertainConstraints[constRef.type_idx].func.terms[varRef]
end
function setUncConstant(model::RobustModel,
    constRef::RobustConstraintRef,
    constVal::Float64,
    )
    model.uncertainConstraints[constRef.type_idx].func.constant = constVal
end
function setUncConstVarCoeff(model::RobustModel,
    constRef::RobustConstraintRef,
    varRef::RobustVariableRef,
    varVal::Float64,
    )
     model.uncertainConstraints[constRef.type_idx].func.terms[varRef] = varVal
end



export lhs,uncConstant,uncConstVarCoeff,setUncConstant,setUncConstVarCoeff

