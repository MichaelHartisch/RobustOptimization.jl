using RobustOptimization
using JuMP
using Test

@testset "RobustOptimization.jl" begin
    # Write your tests here.
    @testset "RobustOptimization.jl" begin
    # Write your tests here.
    @test RobustOptimization.testfunc() == 0
    m = RobustOptimization.RobustModel()
    
    @variable(m, 0 <= y <= 1,RobustOptimization.Uncertain(1))


    @variable(m, 1 <= x_interval <= 3.5,RobustOptimization.Decision(1,"test",m.uncertainVariables))
    #Add VariableTest
    @testset "lowerbound" begin
        #init
        mod = RobustOptimization.RobustModel()
        #add vars
        @variable(mod, 0 <= y <= 1,RobustOptimization.Uncertain(1))
        @variable(mod, 1 <= x_interval <= 3.5,RobustOptimization.Decision(1,"test",mod.uncertainVariables))
        #test add vars
        @test mod.var_to_name[2] == "x_interval"
        @test mod.var_to_name[1] == "y"

        #test infos
        @test has_lower_bound(x_interval) == true
        @test lower_bound(x_interval) == 1.0
        @test has_upper_bound(x_interval) == true
        @test upper_bound(x_interval)== 3.5

        #test setter
        set_lower_bound(x_interval,0.5)
        @test lower_bound(x_interval) == 0.5
        set_upper_bound(x_interval,5.5)
        @test upper_bound(x_interval) == 5.5

        #test start value
        set_start_value(x_interval,2.0)
        @test start_value(x_interval) == 2.0
        
        #test delete
        delete_lower_bound(x_interval)
        @test has_lower_bound(x_interval) == false
        delete_upper_bound(x_interval)
        @test has_upper_bound(x_interval) == false

        #test fixing
        fix(x_interval, 4)
        @test is_fixed(x_interval) == true

        #test unfix
        unfix(x_interval)
        @test is_fixed(x_interval) == false

        #test binary
        set_binary(x_interval)
        @test is_binary(x_interval) == true
        unset_binary(x_interval)
        @test is_binary(x_interval) == false
        
        #test integer
        set_integer(x_interval)
        @test is_integer(x_interval) == true
        unset_integer(x_interval)
        @test is_integer(x_interval) == false

        #test delete
        decLen = length(mod.decisionVariables)
        delete(mod,x_interval) 
        @test length(mod.decisionVariables)-decLen == -1
        
    end

    


 
  

    
    #@constraint(m, c1, 2*x_interval + 2*y_interval <= 10)
    #@objective(m, Max, x_interval + y_interval)
    @test m.var_to_name[2] == "x_interval"
    #TODO get inner of Decision
    @test m.var_to_name[1] == "y"
    @test m.nextvaridx == length(m.uncertainVariables)+length(m.decisionVariables)
    #con =m.uncertainConstraints[RobustOptimization.ConstraintIndex(1)]
    #@test con.set == MathOptInterface.LessThan{Float64}(10.0)

    ########### TEST Variable Basics
    



    print(m.objectivesense)
end

end
