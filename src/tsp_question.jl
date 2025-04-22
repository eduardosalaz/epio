# El Gran Tour del Inspector de Tacos Nacionales
# TSP para visitar todas las capitales de los estados mexicanos
# con visualización utilizando GMT.jl (Generic Mapping Tools)
using Dates
using JuMP
using Gurobi  # Cambiar por HiGHS si no se tiene licencia de Gurobi
using LinearAlgebra
using Statistics
using GMT  # Generic Mapping Tools para visualización geográfica

# 1. LEER DATOS DE ARCHIVO: Capitales de los estados mexicanos
function read_capitals_from_file(filename)
    return capitales
end

# 2. CALCULAR LA MATRIZ DE DISTANCIAS
# Usaremos la distancia haversine para considerar la curvatura terrestre
function haversine(lat1, lon1, lat2, lon2)
    return R * c
end

function calculate_distance_matrix(latitudes, longitudes)
    return dist_matrix
end

# 3. RESOLVER EL TSP CON FORMULACIÓN MTZ
function solve_tsp_capitals(dist_matrix, nombres, start_city_name="Monterrey")


    model = direct_model(Gurobi.Optimizer())
    optimize!(model)

    # Extraer solución
    if termination_status(model) == MOI.OPTIMAL ||
       (termination_status(model) == MOI.TIME_LIMIT && has_values(model))

        # Extraer el tour
        tour = extract_tour(value.(x), n, start_city)
        total_distance = objective_value(model)
        gap = relative_gap(model)

        return tour, total_distance, gap, solve_time(model)
    else
        println("No se encontró solución. Estado: ", termination_status(model))
        return [], Inf, NaN, 0.0
    end
end

# Función para extraer el tour de la matriz x
function extract_tour(x_val, n, start_city)
    tour = [start_city]  # Comenzamos en la ciudad inicial
    current = start_city

    while length(tour) < n
        for j in 1:n
            if j != current && x_val[current, j] > 0.5
                push!(tour, j)
                current = j
                break
            end
        end
    end

    return tour
end

# 4. VISUALIZAR LA SOLUCIÓN CON GMT
# Función de visualización actualizada
function plot_mexico_tsp_with_gmt(tour, nombres, latitudes, longitudes, dist_matrix)
    return true
end

# 5. GENERAR UN ITINERARIO HUMORÍSTICO
function print_taco_tour_itinerary(tour, nombres, dist_matrix)
    println("\n🌮 EL GRAN TOUR DEL INSPECTOR DE TACOS NACIONALES 🌮")
    println("----------------------------------------------------")
    println("MISIÓN: Verificar la autenticidad de los tacos en cada capital estatal")

    total_distance = 0.0
    prev_city = tour[1]

    println("\nITINERARIO:")
    println("Día 1: Inicio en $(nombres[tour[1]]) - ¡Aquí comienza nuestra gran aventura taquera!")

    for i in 2:length(tour)
        current_city = tour[i]
        distance = dist_matrix[prev_city, current_city]
        total_distance += distance

        taco_types = ["al pastor", "de carnitas", "de barbacoa", "de suadero", "de birria",
            "de pescado", "de camarón", "de chicharrón", "de lengua", "de cabeza",
            "de tripa", "campechanos", "de chorizo", "de asada", "vegetarianos"]

        taco_joke = rand([
            "¡El guacamole aquí debe ser investigado por ser ilegalmente delicioso!",
            "Se rumora que aquí las salsas requieren firma de responsabilidad.",
            "Tendré que probar al menos 17 tacos para una evaluación completa.",
            "Dicen que el cilantro local tiene propiedades mágicas.",
            "La tortilla será analizada por su perfecta circunferencia.",
            "Necesitaré verificar si la cebolla está debidamente caramelizada.",
            "Investigación especial sobre la proporción óptima salsa-taco.",
            "Hay reportes de que la salsa hace cantar el himno nacional.",
            "La limosidad del limón será evaluada con criterios estrictos.",
            "La temperatura de la tortilla debe ser certificada por el instituto."
        ])

        println("Día $i: Viaje a $(nombres[current_city]) ($(round(distance, digits=2)) km)")
        println("   🌮 Inspección de tacos $(taco_types[i % length(taco_types) + 1])")
        println("   📝 Nota: $taco_joke")

        prev_city = current_city
    end

    # Volver al inicio
    distance_back = dist_matrix[tour[end], tour[1]]
    total_distance += distance_back

    println("Día $(length(tour)+1): Regreso a $(nombres[tour[1]]) ($(round(distance_back, digits=2)) km)")
    println("   🏁 Fin del tour con un gran taco de victory lap")

    println("\nDISTANCIA TOTAL RECORRIDA: $(round(total_distance, digits=2)) kilómetros")
    println("TACOS PROBADOS: Aproximadamente $(length(tour) * 7) (mínimo 7 por capital)")
    println("BOTELLAS DE SALSA EVALUADAS: $(length(tour) * 3)")
    println("LIMONES EXPRIMIDOS: $(length(tour) * 12)")
    println("\nCONCLUSIÓN: México sigue siendo la superpotencia mundial de tacos.")

    return total_distance
end

# 6. GUARDAR RESULTADOS A UN ARCHIVO
function save_tour_to_file(tour, nombres, dist_matrix, distance, solution_time, gap, filename="resultados_tour_tacos.txt")
    open(filename, "w") do file
        write(file, "🌮 EL GRAN TOUR DEL INSPECTOR DE TACOS NACIONALES 🌮\n")
        write(file, "====================================================\n\n")

        # Información del análisis
        write(file, "INFORMACIÓN DEL ANÁLISIS\n")
        write(file, "----------------------\n")
        write(file, "Fecha: $(Dates.format(Dates.now(), "dd-mm-yyyy HH:MM:SS"))\n")
        write(file, "Tiempo de cálculo: $(round(solution_time, digits=2)) segundos\n")
        write(file, "Gap relativo: $(round(100*gap, digits=2))%\n\n")

        # Información del tour
        write(file, "RUTA ÓPTIMA\n")
        write(file, "----------\n")
        write(file, "Punto de inicio: $(nombres[tour[1]])\n")
        write(file, "Distancia total: $(round(distance, digits=2)) km\n")
        write(file, "Número de ciudades: $(length(tour))\n\n")

        # Secuencia detallada del tour
        write(file, "SECUENCIA DEL TOUR\n")
        write(file, "----------------\n")

        for i in 1:length(tour)
            if i < length(tour)
                leg_distance = dist_matrix[tour[i], tour[i+1]]
                write(file, "$(i). $(nombres[tour[i]]) -> $(nombres[tour[i+1]]) ($(round(leg_distance, digits=2)) km)\n")
            else
                # Último tramo cerrando el circuito
                leg_distance = dist_matrix[tour[i], tour[1]]
                write(file, "$(i). $(nombres[tour[i]]) -> $(nombres[tour[1]]) ($(round(leg_distance, digits=2)) km)\n")
            end
        end

        # Estadísticas adicionales
        write(file, "\nESTADÍSTICAS DEL TOUR\n")
        write(file, "-------------------\n")
        write(file, "Distancia promedio entre ciudades: $(round(distance / length(tour), digits=2)) km\n")

        # Distancia mínima y máxima entre ciudades consecutivas
        distances_between_stops = Float64[]
        for i in 1:length(tour)
            next_idx = i % length(tour) + 1
            push!(distances_between_stops, dist_matrix[tour[i], tour[next_idx]])
        end

        write(file, "Tramo más corto: $(round(minimum(distances_between_stops), digits=2)) km\n")
        write(file, "Tramo más largo: $(round(maximum(distances_between_stops), digits=2)) km\n")

        # Comentario final
        write(file, "\n¡Viva México y sus tacos! 🌮\n")
    end

    println("Resultados guardados en el archivo: $filename")
    return true
end

# 7. FUNCIÓN PRINCIPAL QUE INTEGRA TODO EL PROCESO
function run_taco_inspector_analysis(capitals_file="capitales_mexico.txt",
    start_city="Monterrey",
    output_results="resultados_tour_tacos.txt")
    println("🌮 Iniciando el cálculo de la ruta óptima para el Inspector de Tacos Nacionales...")

    # 1. Cargar datos
    capitales = read_capitals_from_file(capitals_file)

    # Extraer componentes
    nombres = [c[1] for c in capitales]
    latitudes = [c[2] for c in capitales]
    longitudes = [c[3] for c in capitales]
    n = length(capitales)

    # 2. Calcular matriz de distancias
    dist_matrix = calculate_distance_matrix(latitudes, longitudes)

    # Imprimir algunas estadísticas de las distancias
    println("Estadísticas de las distancias (km):")
    println("  Mínima: ", round(minimum(filter(x -> x < 1e6, dist_matrix)), digits=2))
    println("  Máxima: ", round(maximum(filter(x -> x < 1e6, dist_matrix)), digits=2))
    println("  Promedio: ", round(mean(filter(x -> x < 1e6, dist_matrix)), digits=2))

    # 3. Resolver el TSP
    tour, distance, gap, solution_time = solve_tsp_capitals(dist_matrix, nombres, start_city)

    if isempty(tour)
        println("No se pudo encontrar una solución. Abortando.")
        return nothing, nothing
    end

    println("\nSOLUCIÓN ENCONTRADA:")
    println("Tiempo de cálculo: $(round(solution_time, digits=2)) segundos")
    println("Distancia total: $(round(distance, digits=2)) km")
    println("Gap relativo: $(round(100*gap, digits=2))%")

    # Imprimir ruta
    println("\nRUTA ÓPTIMA:")
    for i in eachindex(tour)
        println("$(i). $(nombres[tour[i]])")
    end

    # 4. Generar y mostrar el itinerario humorístico
    total_distance = print_taco_tour_itinerary(tour, nombres, dist_matrix)

    # 5. Visualizar la solución con GMT
    plot_mexico_tsp_with_gmt(tour, nombres, latitudes, longitudes, dist_matrix)

    # 6. Guardar resultados a un archivo
    save_tour_to_file(tour, nombres, dist_matrix, distance, solution_time, gap, output_results)

    println("\n¡La ruta óptima del Inspector de Tacos Nacionales ha sido calculada con éxito! 🌮")

    return tour, distance
end

# Función principal para ejecutar todo el programa
function main()
    # Definir parámetros (podrían provenir de argumentos de línea de comandos)
    capitals_file = "capitales_mexico.txt"
    start_city = "Monterrey"
    output_results = "resultados_tour_tacos.txt"

    # Ejecutar el análisis completo
    tour, distance = run_taco_inspector_analysis(
        capitals_file,
        start_city,
        output_results
    )

    return tour, distance
end

# Patrón estándar de Julia para ejecutar el main solo cuando se ejecuta el script directamente
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
