using JuMP, Gurobi
function main()

    # Paso 1: Resolver el MILP original
    milp_model = Model(Gurobi.Optimizer)

    @variable(milp_model, x_milp >= 0)
    @variable(milp_model, 0 <= y_milp <= 10)
    @variable(milp_model, z_milp, Bin)

    @constraint(milp_model, 2x_milp + y_milp <= 10)
    @constraint(milp_model, x_milp + 5y_milp >= 15)

    @objective(milp_model, Max, 5x_milp + 3y_milp - 2z_milp)

    optimize!(milp_model)

    # Verificar si se encontró solución óptima
    if termination_status(milp_model) == MOI.OPTIMAL
        z_optimal = value(z_milp)
        println("MILP resuelto: z = ", z_optimal)
        println("x = ", value(x_milp))
        println("y = ", value(y_milp))
        println("Valor objetivo MILP: ", objective_value(milp_model))

        # Paso 2: Fijar z y resolver el LP resultante
        lp_model = Model(Gurobi.Optimizer)

        @variable(lp_model, x >= 0)
        @variable(lp_model, 0 <= y <= 10)

        # Fijar el valor de z en la función objetivo
        @constraint(lp_model, con1, 2x + y <= 10)
        @constraint(lp_model, con2, x + 5y >= 15)

        # La función objetivo incorpora el valor fijo de z
        @objective(lp_model, Max, 5x + 3y - 2 * z_optimal)

        optimize!(lp_model)

        if termination_status(lp_model) == MOI.OPTIMAL
            println("\nLP con z fijo resuelto:")
            println("Valor objetivo LP: ", objective_value(lp_model))
            println("x = ", value(x))
            println("y = ", value(y))

            # Ahora sí puedes acceder a los valores duales
            println("\nValores duales:")
            println("Dual de con1: ", dual(con1))
            println("Dual de con2: ", dual(con2))

            # Y también a los costos reducidos
            println("\nCostos reducidos:")
            println("Costo reducido de x: ", reduced_cost(x))
            println("Costo reducido de y: ", reduced_cost(y))
        else
            println("LP no resuelto a optimalidad")
        end
    else
        println("MILP no resuelto a optimalidad")
    end
end

main()