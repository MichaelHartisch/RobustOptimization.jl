#mutable struct UncertainVariableRef <: RobustVariableRef
#end

struct Uncertain <: RobustVariableType
    stage::Int
end

struct UncertainVariable<: RobustVariable
    info::JuMP.VariableInfo
    stage::Int
end
