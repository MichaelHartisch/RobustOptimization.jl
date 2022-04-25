abstract type RobustVariableType end

abstract type VariableType end

abstract type RobustVariable <: JuMP.AbstractVariable end

abstract type RobustVariableRef <: JuMP.AbstractVariableRef end

Base.copy(v::RobustVariableRef) = v


mutable struct UncertainVariableRef <: RobustVariableRef
    model::RobustModel # `model` owning the variable
    idx::Int       # Index of global variable
    type_idx::Int    #Index of this specific type
    Type::Char
end

mutable struct DecisionVariableRef <: RobustVariableRef
    model::RobustModel # `model` owning the variable
    idx::Int       # Index of global variable
    type_idx::Int    #Index of this specific type
    Type::Char
end

abstract type RobustConstraintType end


struct MyTag
    name::String
end

struct RobustConstraint{S} <: AbstractConstraint
    name::String
    f::AffExpr
    s::S
end

function JuMP.build_constraint(
    _error::Function,
    f::AffExpr,
    set::MOI.AbstractScalarSet,
    extra::MyTag
)
    return RobustConstraint(extra.name,f,set)
end

function JuMP.add_constraint(
    model::RobustModel,
    con::RobustConstraint,
    name::String,
)
    return add_constraint(
        model,
        ScalarConstraint(con.f, con.s),
        "$(con.name)[$(name)]",
    )
end

export RobustConstraint, MyTag