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
abstract type RobustConstraint{S} <: AbstractConstraint end
abstract type RobustConstraintRef end 


mutable struct UncertainConstraintRef <: RobustConstraintRef
    model::RobustModel
    idx::Int64
    type_idx::Int    #Index of this specific type
    Type::Char
end

mutable struct UncertaintySetConstraintRef <: RobustConstraintRef
    model::RobustModel
    idx::Int64
    type_idx::Int    #Index of this specific type
    Type::Char
end
abstract type AbstractDataObject end


export RobustConstraint,UncertaintyConstraint,RobustConstraintRef,AbstractDataObject,UncertaintySetConstraintRef