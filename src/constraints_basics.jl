
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
    extra::MyTag,
)
    return RobustConstraint(extra.name,f,set)
end

function JuMP.add_constraint(
    model::Model,
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