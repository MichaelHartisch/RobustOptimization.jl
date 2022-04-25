struct UncertainConstraint <: RobustConstraintType
    name::String
end


struct UncertainConst{S}  <: RobustConstraint{S}
    name::String
    fun::GenericAffExpr
    set::S
end
export UncertainConstraint,UncertainConst