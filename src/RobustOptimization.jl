module RobustOptimization
using JuMP
using HiGHS
const MutableArithmetics = JuMP._MA;

struct AddTwice
    info::JuMP.VariableInfo
end
function JuMP.build_variable(
    _err::Function,
    info::JuMP.VariableInfo,
    ::Type{AddTwice};
    kwargs...
)
    println("Can also use $kwargs here.")
    return AddTwice(info)
end
function JuMP.add_variable(
    model::JuMP.Model,
    duplicate::AddTwice,
    name::String,
)
    a = JuMP.add_variable(
        model,
        JuMP.ScalarVariable(duplicate.info),
        name * "_a",
     )
    b = JuMP.add_variable(
        model,
        JuMP.ScalarVariable(duplicate.info),
        name * "_b",
     )
    return (a, b)
end



testfunc() = 0
end
