using RobustOptimization
using JuMP
using Test

@testset "RobustOptimization.jl" begin
    # Write your tests here.
    @testset "RobustOptimization.jl" begin
    # Write your tests here.
    @test RobustOptimization.testfunc() == 0
    m = RobustOptimization.RobustModel()
    @variable(m, 2 <= x_interval <= 3.5,RobustOptimization.Decision(2))
    @variable(m, 0 <= y <= 1,RobustOptimization.Uncertain(2))
    #@constraint(m, c1, 2*x_interval + 2*y_interval <= 10)
    #@objective(m, Max, x_interval + y_interval)
    @test m.var_to_name[1] == "x_interval"
    @test m.var_to_name[2] == "y"
    @test m.nextvaridx == length(m.uncertainVariables)+length(m.decisionVariables)
    #con =m.uncertainConstraints[RobustOptimization.ConstraintIndex(1)]
    #@test con.set == MathOptInterface.LessThan{Float64}(10.0)

    print(m.objectivesense)
end

end
