using JuMP
using Gurobi 

function modelo_original()
    weights = [7, 9, 5, 8, 4, 6, 3, 10, 5, 7, 6, 4, 8, 3, 9]
    capacity = 20
    n = length(weights)
    m = n

    model = Model(Gurobi.Optimizer)
    set_optimizer_attribute(model, "OutputFlag", 0)

    @variable(model, x[1:n, 1:m], Bin)
    @variable(model, y[1:m], Bin)

    for i in 1:n
        @constraint(model, sum(x[i,j] for j in 1:m) == 1)
    end

    for j in 1:m
        @constraint(model, sum(weights[i] * x[i,j] for i in 1:n) <= capacity * y[j])
        @constraint(model, [i=1:n], x[i,j] <= y[j])
    end

    for j in 2:m
        @constraint(model, y[j] <= y[j-1])
    end

    @objective(model, Min, sum(y[j] for j in 1:m))

    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        println("Contenedores usados: ", sum(value.(y)))
        for j in 1:Int(sum(value.(y)))
            items = findall(x -> x > 0.5, value.(x[:,j]))
            println("Contenedor $j: $items")
        end
    end
end

function modelo_modificado()
    weights = [7, 9, 5, 8, 4, 6, 3, 10, 5, 7, 6, 4, 8, 3, 9]
    capacity = 20
    n = length(weights)
    m = n

    model = Model(Gurobi.Optimizer)
    set_optimizer_attribute(model, "OutputFlag", 0)

    @variable(model, x[1:n, 1:m], Bin)
    @variable(model, y[1:m], Bin)

    # Restricciones originales
    for i in 1:n
        @constraint(model, sum(x[i,j] for j in 1:m) == 1)
    end

    for j in 1:m
        @constraint(model, sum(weights[i] * x[i,j] for i in 1:n) <= capacity * y[j])
        @constraint(model, [i=1:n], x[i,j] <= y[j])
    end

    for j in 2:m
        @constraint(model, y[j] <= y[j-1])
    end

    # Restricción adicional
    for j in 1:m
        @constraint(model, x[1,j] + x[5,j] <= 1)
    end

    @objective(model, Min, sum(y[j] for j in 1:m))

    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        println("\nCon restricción:")
        println("Contenedores usados: ", sum(value.(y)))
        for j in 1:Int(sum(value.(y)))
            items = findall(x -> x > 0.5, value.(x[:,j]))
            println("Contenedor $j: $items")
        end
    end
end

function main()
    modelo_original()
    modelo_modificado()
end
main()