struct UncertaintySetConstraint <: RobustConstraintType
    name::String
end

struct UncertaintySetConst{S} <: RobustConstraint{S}
    name::String
    fun::GenericAffExpr
    set::S
end

export UncertaintySetConstraint, UncertaintySetConst