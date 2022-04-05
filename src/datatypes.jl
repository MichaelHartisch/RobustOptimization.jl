abstract type RobustVariableType end

abstract type VariableType end

abstract type RobustVariable <: JuMP.AbstractVariable end

abstract type RobustVariableRef <: JuMP.AbstractVariableRef end

Base.copy(v::RobustVariableRef) = v


mutable struct UncertainVariableRef <: RobustVariableRef
    model::RobustModel # `model` owning the variable
    variable_index::Int       # Index of global variable
    type_variable_index::Int    #Index of this specific type
    Type::Char
end

mutable struct DecisionVariableRef <: RobustVariableRef
    model::RobustModel # `model` owning the variable
    variable_index::Int       # Index of global variable
    type_variable_index::Int    #Index of this specific type
    Type::Char
end
