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
    capitales = []
    open(filename, "r") do file
        for line in eachline(file)
            # Saltar líneas vacías o comentarios
            if isempty(strip(line)) || startswith(strip(line), "#")
                continue
            end

            # Analizar cada línea
            parts = split(line, ",")
            if length(parts) >= 3
                name = strip(parts[1])
                lat = parse(Float64, strip(parts[2]))
                lon = parse(Float64, strip(parts[3]))
                push!(capitales, (name, lat, lon))
            end
        end
    end

    println("Se han cargado $(length(capitales)) capitales desde el archivo.")
    return capitales
end

# 2. CALCULAR LA MATRIZ DE DISTANCIAS
# Usaremos la distancia haversine para considerar la curvatura terrestre
function haversine(lat1, lon1, lat2, lon2)
    # Radio de la Tierra en kilómetros
    R = 6371.0

    # Convertir grados a radianes
    lat1_rad = lat1 * π / 180
    lon1_rad = lon1 * π / 180
    lat2_rad = lat2 * π / 180
    lon2_rad = lon2 * π / 180

    # Diferencias
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad

    # Fórmula haversine
    a = sin(dlat / 2)^2 + cos(lat1_rad) * cos(lat2_rad) * sin(dlon / 2)^2
    c = 2 * atan(sqrt(a), sqrt(1 - a))

    # Distancia en kilómetros
    return R * c
end

function calculate_distance_matrix(latitudes, longitudes)
    n = length(latitudes)
    dist_matrix = zeros(n, n)
    for i in 1:n
        for j in 1:n
            if i != j
                dist_matrix[i, j] = haversine(latitudes[i], longitudes[i], latitudes[j], longitudes[j])
            else
                dist_matrix[i, j] = 1e6  # Valor grande para no permitir loops
            end
        end
    end
    return dist_matrix
end

# 3. RESOLVER EL TSP CON FORMULACIÓN MTZ
function solve_tsp_capitals(dist_matrix, nombres, start_city_name="Monterrey")
    function subtour_elim(cb_data, cb_where::Cint)
        # Esta función de callback es llamada en diferentes etapas de la optimización
        if cb_where == GRB_CB_MIPSOL
            # Carga los valores de la solución actual desde el solver
            Gurobi.load_callback_variable_primal(cb_data, cb_where)
            # Obtiene los valores de todas las variables x en la solución actual
            x_sol = callback_value.(cb_data, x)
            # Obtiene las dimensiones de la matriz de distancias
            n, m = size(dist_matrix)
            # Reorganiza el vector solución a una matriz
            x_sol = reshape(x_sol, n, m)
            # Convierte los valores de la solución a binarios (0 o 1)
            x_sol .= x_sol .> 0.5
            # Crea un diccionario para rastrear la siguiente ciudad desde cada ciudad
            next = Dict{Int,Int}()
            for i in 1:n
                for j in 1:n
                    # Si hay una arista de i a j (x_sol[i,j] = 1)
                    if i != j && x_sol[i, j] == 1
                        # La ciudad j sigue a la ciudad i en el recorrido
                        next[i] = j
                    end
                end
            end
            # Inicializa un arreglo para rastrear qué ciudades han sido visitadas
            visited = falses(n)
            # Inicializa un vector para almacenar todos los subcircuitos encontrados
            subtours = Vector{Vector{Int}}()
            # Itera a través de todas las ciudades
            for i in 1:n
                # Si la ciudad i aún no ha sido visitada
                if !visited[i]
                    # Comienza un nuevo subcircuito en la ciudad i
                    current = i
                    cycle = Int[]
                    # Sigue el camino hasta regresar a la ciudad inicial
                    while true
                        # Añade la ciudad actual al ciclo
                        push!(cycle, current)
                        # Marca la ciudad actual como visitada
                        visited[current] = true
                        # Avanza a la siguiente ciudad en el camino
                        current = next[current]
                        # Si hemos regresado a la ciudad inicial, rompe el ciclo
                        current == i && break
                    end
                    # Añade el ciclo completo a la lista de subcircuitos
                    push!(subtours, cycle)
                end
            end
            # Si se encuentra más de un subcircuito, añade restricciones para eliminarlos
            if length(subtours) > 1
                for S in subtours
                    # Si este subcircuito no incluye todas las ciudades
                    if length(S) < n
                        # Crea una restricción: la suma de aristas dentro del subcircuito debe ser <= |S|-1
                        # Esto fuerza a la solución a incluir al menos una arista que salga del subcircuito
                        edge_sum = sum(x[i, j] for i in S, j in S if i != j)
                        con = @build_constraint(edge_sum <= length(S) - 1)
                        # Envía esta restricción perezosa al solver
                        MOI.submit(model, MOI.LazyConstraint(cb_data), con)
                    end
                end
            end
        end
    end

    n = size(dist_matrix, 1)

    model = direct_model(Gurobi.Optimizer())
    MOI.set(model, MOI.RawOptimizerAttribute("OutputFlag"), 1)  # Mostrar output del solver
    MOI.set(model, MOI.RawOptimizerAttribute("TimeLimit"), 300)  # Límite de 5 minutos
    MOI.set(model, MOI.RawOptimizerAttribute("LazyConstraints"), 1)
    MOI.set(model, Gurobi.CallbackFunction(), subtour_elim)

    # Variables de decisión
    @variable(model, x[1:n, 1:n], Bin)  # x[i,j] = 1 si vamos de ciudad i a j

    # Función objetivo: minimizar la distancia total
    @objective(model, Min, sum(dist_matrix[i, j] * x[i, j] for i in 1:n, j in 1:n))

    # Restricciones
    for i in 1:n
        # Cada ciudad tiene exactamente una salida
        @constraint(model, sum(x[i, j] for j in 1:n if i != j) == 1)

        # Cada ciudad tiene exactamente una entrada
        @constraint(model, sum(x[j, i] for j in 1:n if i != j) == 1)
    end
    # Resolver
    optimize!(model)

    start_idx = findfirst(nombre -> nombre == start_city_name, nombres)
    if isnothing(start_idx)
        # Si no encontramos la ciudad, usar la primera ciudad
        start_idx = 1
        println("ADVERTENCIA: No se encontró '$start_city_name'. Usando $(nombres[1]) como ciudad inicial.")
    else
        println("Usando $(nombres[start_idx]) como ciudad inicial (índice $start_idx).")
    end

    # Empezar en la ciudad inicial
    start_city = start_idx

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
    # Preparar datos del tour
    tour_lons = longitudes[tour]
    tour_lats = latitudes[tour]

    # Añadir el punto inicial al final para cerrar el circuito
    push!(tour_lons, tour_lons[1])
    push!(tour_lats, tour_lats[1])

    # Crear matriz para el tour (el formato correcto para GMT)
    tour_coords = hcat(tour_lons, tour_lats)

    # Calcular distancia total
    total_dist = sum(dist_matrix[tour[i], tour[i%length(tour)+1]] for i in eachindex(tour))

    # Configurar región y proyección optimizada para México
    region = [-118.5, -86.0, 14.0, 33.5]

    figure_size = 15

    # Crear mapa base - corregido según la sintaxis de GMT.jl
    coast(
        region=region,
        proj=:Mercator,
        land=:tan2,              # Improved land color
        water=:skyblue,          # Improved water color
        shore=:thin,             # Slightly thicker shorelines
        DCW="MX+p0.5p",  # State borders,
        borders=2,
        frame=:WSen,
        figsize=figure_size,
        resolution=:full,
        title="El Gran Tour del Inspector de Tacos Nacionales"
    )

    # Añadir ruta TSP con la sintaxis correcta de GMT
    plot!(tour_coords, pen="1.1p,tomato")

    # Crear datos para las ciudades
    cities_coords = hcat(longitudes, latitudes)

    # Añadir ciudades con la sintaxis correcta
    plot!(cities_coords, marker=:square, markersize=0.15,
        markerfacecolor=:dodgerblue, markeredgecolor=:black)

    # Encontrar el índice de la ciudad inicial para destacarla
    start_idx = tour[1]
    start_coords = [longitudes[start_idx] latitudes[start_idx]]
    plot!(start_coords, marker=:star, markersize=0.2,
        markerfacecolor=:yellow, markeredgecolor=:black)

    # Añadir información de distancia
    if total_dist > 0
        text!([region[1] + 1.5 region[3] + 1.0],
            text="Distancia Total: $(round(Int, total_dist)) km",
            font=(10, "Helvetica-Bold"),
            justify=:LB, show=true)
    end

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
