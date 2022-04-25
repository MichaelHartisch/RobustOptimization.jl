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
abstract type ConstraintType end
abstract type AbstractRobustIndex end
abstract type ObjectIndex <: AbstractRobustIndex end


struct RobustConstraintIndex <: ObjectIndex
    value::Int64
end

abstract type  RobustConstraintRef end 


mutable struct UncertainConstraintRef <: RobustConstraintRef
    model::RobustModel
    index::RobustConstraintIndex
    type_idx::Int    #Index of this specific type
    Type::Char
end

mutable struct UncertaintySetConstraintRef <: RobustConstraintRef
    model::RobustModel
    index::RobustConstraintIndex
    type_idx::Int    #Index of this specific type
    Type::Char
end

struct UncertaintySetConstraint <: RobustConstraintType
    name::String
end
struct UncertainConstraint <: RobustConstraintType
    name::String
end


abstract type RobustConstraint{S} <: AbstractConstraint
end

struct UncertainConst{S}  <: RobustConstraint{S}
    name::String
    fun::GenericAffExpr
    set::S
end

struct UncertaintySetConst{S} <: RobustConstraint{S}
    name::String
    fun::GenericAffExpr
    set::S
end

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
    print("Index of new Constraint will be ",model.nextconidx ,"\n")
    print(typeof(con))

end

export RobustConstraint, UncertaintySetConstraint,UncertainConstraint,UncertaintyConstraint,RobustConstraintRef