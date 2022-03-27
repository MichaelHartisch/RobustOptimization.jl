using RobustOptimization
using Test

@testset "RobustOptimization.jl" begin
    # Write your tests here.
    @test RobustOptimization.testfunc() == 0
    @test RobustOptimization.name(RobustOptimization.RobustModel("test")) == "test"
    @test RobustOptimization.name(RobustOptimization.Uncertain(RobustOptimization.RobustModel("test"),"x",10,14)) == "x"
    @test RobustOptimization.lower(RobustOptimization.Uncertain(RobustOptimization.RobustModel("test"),"x",10,14)) == 10
    @test RobustOptimization.upper(RobustOptimization.Uncertain(RobustOptimization.RobustModel("test"),"x",10,14)) == 14
    @test RobustOptimization.showMe(RobustOptimization.Uncertain(RobustOptimization.RobustModel("test"),"x",10,14)) == true
end

