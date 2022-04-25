

struct MyTag
    name::String
end

struct RobustConstraint{S} <: AbstractConstraint
    name::String
    f::AffExpr
    s::S
end

export RobustConstraint, MyTag