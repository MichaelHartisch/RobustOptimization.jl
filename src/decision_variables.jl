#mutable struct DecisionVariableRef <: RobustVariableRef
#end

struct Decision <: RobustVariableType
    stage::Int
    policy::String
    depends_on::Dict{Int64, AbstractVariable}
end

struct DecisionVariable<: RobustVariable
    info::JuMP.VariableInfo
    stage::Int
    policy::String
    depends_on::Dict{Int64, AbstractVariable}
end

#Decision abhängig von Uncertain
# policy und depends on
# policy ist ein keyord wie affine was dann nachher einen switch 
# depends on  nur im DECISIOSN= Vektor mit UNcerstain variable die definiert sein müssen
