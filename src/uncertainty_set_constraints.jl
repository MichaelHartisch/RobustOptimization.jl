struct UncertaintySetConstraint <: RobustConstraintType
    name::String
end

struct UncertaintySetConst{S} <: RobustConstraint{S}
    name::String
    func::GenericAffExpr
    set::S
end

export UncertaintySetConstraint, UncertaintySetConst