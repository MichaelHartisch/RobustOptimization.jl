
"""
define Uncertain
define Szenario

max c1x1+c2x2
st. w1x1 +w2x2 <= C

pre
U w3 w4 
w3 = p1u11 +p2u11
w4 = p1u12 + p2u22
 p1+p2 = 1

 scenarios [1 2; 3 4], [:a, :b], 2:3
"""

import JuMP

struct SoysterUncertain
    scenarios::JuMP.Containers
    
end
x= Matrix[(0.95,1.35),(1.25,1.25)]
SoysterUncertain(Containers.@container(x)
