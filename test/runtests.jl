using RobustOptimization
using Test
using InfiniteOpt, Ipopt
using MathOptInterface
@testset "RobustOptimization.jl" begin
    # Write your tests here.
    @test RobustOptimization.testfunc() == 0
    opt = Ipopt.Optimizer
    m = RobustOptimization.RobustModel()
    @variable(m, 2 <= x_interval <= 3.5)
    @variable(m, 2 <= y_interval <= 3.5)
    @constraint(m, c1, 2*x_interval + 2*y_interval <= 10)
    @objective(m, Max, x_interval + y_interval)
    @test m.var_to_name[1] == "x_interval"
    @test m.var_to_name[2] == "y_interval"

    con =m.uncertainConstraints[RobustOptimization.ConstraintIndex(1)]
    @test con.set == MathOptInterface.LessThan{Float64}(10.0)

    print(m.objectivesense)
end

