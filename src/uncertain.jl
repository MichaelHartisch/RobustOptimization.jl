import JuMP

struct RobustModel 
    name::AbstractString
end
name(rm::RobustModel) = rm.name
rob = RobustModel("RobustModel")
"""
Uncertain is defined like an variable and depends to an Model 
"""

struct Uncertain
    rm::RobustModel
    name::AbstractString
    lower::Number
    upper::Number
end
"""large declaration"""
function name(unc::Uncertain) 
    return unc.name
end
"""Getter"""
lower(unc::Uncertain) = unc.lower
upper(unc::Uncertain) = unc.upper
function showMe(unc::Uncertain)
    print("Name: ",unc.name,", lower: ",unc.lower,", upper: ", unc.upper)
    return true
end

unc = Uncertain(rob,"2",10,14)
#showMe(unc)
