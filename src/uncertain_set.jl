
#@UncertaintySet(rm,type=scenario {Basic,Budgeted}, C)

macro UncertaintySet(model::RobustModel,
    type::String,#AnotherType
    C::String,#Datatype??
    )
    return :( println("Hello, world!") )
end