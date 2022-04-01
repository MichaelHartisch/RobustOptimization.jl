using RobustOptimization
using Test
using JuMP
@testset "RobustOptimization.jl" begin
    # Write your tests here.
    MutableArithmetics = JuMP._MA;
    @test RobustOptimization.testfunc() == 0
    model = Model();
    @variable(model, x[i=1:2], RobustOptimization.AddTwice, kw=i)
    @test num_variables(model) == 4
    print(model)
end

