#mutable struct DecisionVariableRef <: RobustVariableRef
#end

struct Decision <: RobustVariableType
    stage::Int
end

struct DecisionVariable<: RobustVariable
    info::JuMP.VariableInfo
    stage::Int
end
