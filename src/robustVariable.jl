import JuMP


struct robustVariable
    test:Int16
end

function JuMP.build_variable(_error::Function, ::Type{robustVariable})
    return robustVariable()
end

function JuMP.add_variable(m::JuMP.Model, v::robustVariable, name::String="")
    vari = JuMP.add_variable(
        m,
        v,
        name
    )
    return vari
end