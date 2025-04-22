using JuMP
using Gurobi
using CSV, DataFrames

function leer_datos_csv(ruta_archivo)
    df = CSV.read(ruta_archivo, DataFrame)
    cost = Matrix(df[:, 2:end])  # Extraer matriz numérica
    trabajadores = df[:, 1]
    return df, cost, trabajadores
end

function modelo_asignacion_basico(cost, trabajadores)
    n = size(cost, 1)
    model = Model(Gurobi.Optimizer)
    set_optimizer_attribute(model, "OutputFlag", 0)

    @variable(model, x[1:n, 1:n], Bin)

    for i in 1:n
        @constraint(model, sum(x[i,j] for j in 1:n) == 1)
        @constraint(model, sum(x[j,i] for j in 1:n) == 1)
    end

    @objective(model, Min, sum(cost[i,j] * x[i,j] for i in 1:n, j in 1:n))

    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        println("\nAsignaciones óptimas:")
        for i in 1:n
            for j in 1:n
                if value(x[i,j]) > 0.9
                    println("$(trabajadores[i]) → Tarea $j")
                end
            end
        end
    end
    return model
end

function modelo_con_restriccion(cost, trabajadores, restricciones)
    n = size(cost, 1)
    model = Model(Gurobi.Optimizer)
    set_optimizer_attribute(model, "OutputFlag", 0)

    @variable(model, y[1:n, 1:n], Bin)

    for i in 1:n
        @constraint(model, sum(y[i,j] for j in 1:n) == 1)
        @constraint(model, sum(y[j,i] for j in 1:n) == 1)
    end

    for (i,j) in keys(restricciones)
        @constraint(model, y[i,j] == 0)
    end

    @objective(model, Min, sum(cost[i,j] * y[i,j] for i in 1:n, j in 1:n))

    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        println("\nAsignaciones con restricciones:")
        for i in 1:n
            for j in 1:n
                if value(y[i,j]) > 0.9
                    println("$(trabajadores[i]) → Tarea $j")
                end
            end
        end
    end
    return model
end

function main()
    df, cost, trabajadores = leer_datos_csv("datos.csv")
    
    modelo_basico = modelo_asignacion_basico(cost, trabajadores)
    restricciones = Dict((1,5) => 0)
    modelo_restringido = modelo_con_restriccion(cost, trabajadores, restricciones)
    
    if termination_status(modelo_basico) == MOI.OPTIMAL && 
       termination_status(modelo_restringido) == MOI.OPTIMAL
        println("\nComparación:")
        println("Diferencia de costo: ", objective_value(modelo_restringido) - objective_value(modelo_basico))
    end
end
main()