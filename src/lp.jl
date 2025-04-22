using JuMP
using Gurobi

function modelo_original()
    """
    Implementa el modelo básico de programación lineal
    """
    model = Model(Gurobi.Optimizer)
    set_optimizer_attribute(model, "OutputFlag", 0)

    @variable(model, x₁ >= 0)  # Bebida Regular
    @variable(model, x₂ >= 0)  # Bebida Light

    @constraint(model, restriccion_agua, 5*x₁ + 6*x₂ <= 60)  # Agua
    @constraint(model, restriccion_concentrado, 2*x₁ + x₂ <= 15)    # Concentrado

    @objective(model, Max, 3*x₁ + 2*x₂)    # Beneficio total

    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        println("Solución óptima encontrada:")
        println("Bebida Regular (x₁): ", round(value(x₁), digits=2), " litros")
        println("Bebida Light (x₂): ", round(value(x₂), digits=2), " litros")
        println("Beneficio total: \$", round(objective_value(model), digits=2))
    else
        println("No se encontró solución óptima.")
    end
end

function modelo_bebida_light()
    model = Model(Gurobi.Optimizer)
    set_optimizer_attribute(model, "OutputFlag", 0)

    @variable(model, x₁ >= 0)
    @variable(model, x₂ >= 0)

    @constraint(model, restriccion_agua, 5*x₁ + 6*x₂ <= 60)
    @constraint(model, restriccion_concentrado, 2*x₁ + x₂ <= 15)

    @objective(model, Max, 3*x₁ + 2.5*x₂)  # Beneficio modificado

    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        println("\nCon beneficio de Bebida Light = \$2.5:")
        println("Bebida Regular: ", round(value(x₁), digits=2))
        println("Bebida Light: ", round(value(x₂), digits=2))
        println("Beneficio total: \$", round(objective_value(model), digits=2))
    end
end

function modelo_concentrado()
    model = Model(Gurobi.Optimizer)
    set_optimizer_attribute(model, "OutputFlag", 0)

    @variable(model, x₁ >= 0)
    @variable(model, x₂ >= 0)

    @constraint(model, restriccion_agua, 5*x₁ + 6*x₂ <= 60)
    @constraint(model, restriccion_concentrado, 2*x₁ + x₂ <= 20)  # Concentrado aumentado

    @objective(model, Max, 3*x₁ + 2*x₂)

    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        println("\nCon concentrado = 20 litros:")
        println("Bebida Regular: ", round(value(x₁), digits=2))
        println("Bebida Light: ", round(value(x₂), digits=2))
        println("Beneficio total: \$", round(objective_value(model), digits=2))
        
        # Precios sombra
        println("\nPrecios sombra originales:")
        println("Agua: \$", round(dual(model[:restriccion_agua]), digits=2))
    end
end

function main()
    modelo_original()
    modelo_bebida_light()
    modelo_concentrado()
end
main()