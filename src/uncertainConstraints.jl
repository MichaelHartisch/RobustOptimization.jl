
# Constraints
const UncertainConstraintRef = JuMP.ConstraintRef{RobustModel,ConstraintIndex}
function JuMP.add_constraint(
    model::RobustModel,
    c::JuMP.AbstractConstraint,
    name::String = "",
)
    model.nextconidx += 1
    index = ConstraintIndex(model.nextconidx)
    #print("INDEX: ", index)
    cref = JuMP.ConstraintRef(model, index, JuMP.shape(c))
    model.uncertainConstraints[index] = c
    JuMP.set_name(cref, name)
    return cref
end
function JuMP.delete(model::RobustModel, constraint_ref::UncertainConstraintRef)
    @assert JuMP.is_valid(model, constraint_ref)
    delete!(model.uncertainConstraints, constraint_ref.index)
    return delete!(model.con_to_name, constraint_ref.index)
end
function JuMP.delete(model::RobustModel, con_refs::Vector{<:UncertainConstraintRef})
    return JuMP.delete.(model, con_refs)
end
function JuMP.is_valid(model::RobustModel, constraint_ref::UncertainConstraintRef)
    return (
        model === constraint_ref.model &&
        constraint_ref.index in keys(model.uncertainConstraints)
    )
end
function JuMP.constraint_object(cref::UncertainConstraintRef)
    return cref.model.uncertainConstraints[cref.index]
end
function JuMP.num_constraints(
    model::RobustModel,
    F::Type{<:JuMP.AbstractJuMPScalar},
    S::Type{<:MOI.AbstractSet},
)
    return count(
        con -> con isa JuMP.ScalarConstraint{F,S},
        values(model.uncertainConstraints),
    )
end
function JuMP.num_constraints(
    model::RobustModel,
    ::Type{<:Vector{F}},
    S::Type{<:MOI.AbstractSet},
) where {F<:JuMP.AbstractJuMPScalar}
    return count(
        con -> con isa JuMP.VectorConstraint{F,S},
        values(model.uncertainConstraints),
    )
end