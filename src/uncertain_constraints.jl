struct UncertainConstraint <: RobustConstraintType
    name::String
end


struct UncertainConst{S}  <: RobustConstraint{S}
    name::String
    func::GenericAffExpr
    set::S
end
export UncertainConstraint,UncertainConst