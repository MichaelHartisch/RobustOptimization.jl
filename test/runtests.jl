using RobustOptimization
using JuMP
using Test
using MathOptInterface
const MOI = MathOptInterface
@testset "RobustOptimization.jl" begin
    # Write your tests here.
    @testset "RobustOptimization.jl" begin
    # Write your tests here.
  
    m = RobustModel()
    
    @variable(m, 0 <= y <= 1,Uncertain(1))


    @variable(m, 1 <= x_interval <= 3.5,Decision(1,"test",m.uncertainVariables))
    #Add VariableTest
    @testset "variables" begin
        #init
        mod = RobustModel()
        #add vars
        @variable(mod, 0 <= y <= 1,Uncertain(1))
        @variable(mod, 0 <= z <= 1,Uncertain(1))
        @variable(mod, 1 <= x_interval <= 3.5,Decision(1,"test",mod.uncertainVariables))

       
        #test add vars
        @test mod.var_to_name[3] == "x_interval"
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

    @testset "constraints" begin
        model = RobustModel() 
        @variable(model, 0 <= y <= 1,Uncertain(1))
        @variable(model, 0 <= x <= 1,Uncertain(1))
        
        @constraint(model, modConst, 2y <= 2, UncertainConstraint("2"))
        @constraint(model, uncConst, 1.5x >= 1, UncertaintySetConstraint("1"))
        @test name(uncConst) == "uncConst"
        
        
      
        print("TESTETSTETS")
        
        @test string(lhs(model,modConst)) == "2 y - 2"
        
        
        setUncConstant(model,uncConst,-3.0)
        @test uncConstant(model,uncConst) == -3.0
        setUncConstVarCoeff(model,uncConst,y,3.0)
        @test uncConstVarCoeff(model,uncConst,y) == 3.0
   
       
        print(model,"\n")

    end


    
    #@constraint(m, c1, 2*x_interval + 2*y_interval <= 10)
    #@objective(m, Max, x_interval + y_interval)
    @test m.var_to_name[2] == "x_interval"
    #TODO get inner of Decision
    @test m.var_to_name[1] == "y"
    @test m.nextvaridx == length(m.uncertainVariables)+length(m.decisionVariables)
    #con =m.uncertainConstraints[RobustOptimization.Int(1)]
    #@test con.set == MathOptInterface.LessThan{Float64}(10.0)

    ########### TEST Variable Basics
    



    print(m.objectivesense)
end

end
