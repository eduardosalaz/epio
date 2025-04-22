# Ejercicios Prácticos: Modelado Matemático con Julia y JuMP

## Ejercicio 1: Programación Lineal Básica

### Objetivo
Familiarizarse con la sintaxis básica de JuMP implementando un problema simple de programación lineal.

### Problema: Mezcla de Productos
Una empresa produce dos tipos de bebidas: Regular y Light. Cada bebida requiere agua y concentrado en las siguientes cantidades:

- Bebida Regular: 5 litros de agua y 2 litros de concentrado
- Bebida Light: 6 litros de agua y 1 litro de concentrado

La empresa dispone diariamente de 60 litros de agua y 15 litros de concentrado. El beneficio por cada litro de Bebida Regular es de $3, mientras que para la Bebida Light es de $2.

### Tareas
1. Formular el problema matemáticamente
2. Implementar el modelo en JuMP
3. Resolver e interpretar la solución
4. Realizar análisis de sensibilidad:
   - ¿Qué pasaría si el beneficio de la Bebida Light aumentara a $2.5?
   - ¿Cómo cambia la solución si la disponibilidad de concentrado aumenta a 20 litros? y ¿Cuáles son los duales de mis restricciones?

### Plantilla de código

```julia
using JuMP
using Gurobi  # O cualquier otro solver instalado
function modelo_original()
    """
    Implementa el modelo básico de programación lineal
    """
    # Crear modelo
    model = Model(Gurobi.Optimizer)

    # Definir variables
    # COMPLETAR: Definir variables para las cantidades de bebidas a producir

    # Definir restricciones
    # COMPLETAR: Añadir restricciones de recursos disponibles

    # Definir función objetivo
    # COMPLETAR: Maximizar el beneficio total

    # Resolver el modelo
    optimize!(model)

    # Verificar estatus e imprimir solución
    if termination_status(model) == MOI.OPTIMAL
        println("Solución óptima encontrada:")
        # COMPLETAR: Imprimir la cantidad óptima de cada bebida y el beneficio total
    else
        println("No se encontró solución óptima. Estado: ", termination_status(model))
    end
end

function modelo_bebida_light()
    """
    Implementa el modelo básico de programación lineal modificando el beneficio de la bebida light
    """
    # Crear modelo
    model = Model(Gurobi.Optimizer)

    # Definir variables
    # COMPLETAR: Definir variables para las cantidades de bebidas a producir

    # Definir restricciones
    # COMPLETAR: Añadir restricciones de recursos disponibles

    # Definir función objetivo
    # COMPLETAR: Maximizar el beneficio total, modificar para tomar en cuenta cambio

    # Resolver el modelo
    optimize!(model)

    # Verificar estatus e imprimir solución
    if termination_status(model) == MOI.OPTIMAL
        println("Solución óptima encontrada:")
        # COMPLETAR: Imprimir la cantidad óptima de cada bebida y el beneficio total
    else
        println("No se encontró solución óptima. Estado: ", termination_status(model))
    end
end

function modelo_concentrado()
    """
    Implementa el modelo básico de programación lineal modificando disponibilidad del concentrado
    """
    # Crear modelo
    model = Model(Gurobi.Optimizer)

    # Definir variables
    # COMPLETAR: Definir variables para las cantidades de bebidas a producir

    # Definir restricciones
    # COMPLETAR: Añadir restricciones de recursos disponibles, modificar para tomar en cuenta el cambio

    # Definir función objetivo
    # COMPLETAR: Maximizar el beneficio total

    # Resolver el modelo
    optimize!(model)

    # Verificar estatus e imprimir solución
    if termination_status(model) == MOI.OPTIMAL
        println("Solución óptima encontrada:")
        # COMPLETAR: Imprimir la cantidad óptima de cada bebida y el beneficio total
        
        # COMPLETAR: Imprimir los valores duales (precios sombra) de las restricciones
    else
        println("No se encontró solución óptima. Estado: ", termination_status(model))
    end
end

function main()
    modelo_original()
    modelo_bebida_light()
    modelo_concentrado()
end
main()
```

## Ejercicio 2: Problema de Asignación

### Objetivo
Implementar un problema clásico de asignación utilizando programación lineal entera, aprendiendo a:
1. Leer datos de entrada desde un archivo CSV
2. Formular el modelo matemático
3. Implementar restricciones adicionales
4. Analizar y comparar diferentes soluciones

### Problema: Asignación de Tareas
Una empresa debe asignar 5 trabajadores a 5 tareas diferentes. Cada trabajador puede realizar cualquier tarea, pero con diferentes niveles de eficiencia. La matriz de costos (en horas) para que cada trabajador realice cada tarea es la siguiente:

| Trabajador/Tarea | Tarea 1 | Tarea 2 | Tarea 3 | Tarea 4 | Tarea 5 |
|------------------|---------|---------|---------|---------|---------|
| Salvador         | 7       | 5       | 9       | 8       | 6       |
| Emmanuel         | 8       | 4       | 7       | 9       | 10      |
| Saúl             | 6       | 8       | 5       | 7       | 9       |
| Isaac            | 9       | 7       | 8       | 6       | 5       |
| Carlos           | 5       | 9       | 6       | 8       | 7       |

Cada trabajador debe ser asignado exactamente a una tarea, y cada tarea debe ser realizada por exactamente un trabajador. El objetivo es minimizar el tiempo total para completar todas las tareas.

Los datos de eficiencia (en horas requeridas) están almacenados en un archivo CSV con el siguiente formato:
```
trabajador,tarea1,tarea2,tarea3,tarea4,tarea5
Salvador,7,5,9,8,6
Emmanuel,8,4,7,9,10
Saúl,6,8,5,7,9
Isaac,9,7,8,6,5
Carlos,5,9,6,8,7
```

### Restricciones
Cada trabajador debe ser asignado a exactamente una tarea
Cada tarea debe ser realizada por exactamente un trabajador
(Posteriormente) Salvador no puede realizar la Tarea 3

### Tareas
1. Leer los datos del archivo CSV
2. Implementar el modelo básico de asignación
3. Resolver e interpretar la solución óptima
4. Modificar el modelo para incluir restricciones adicionales
5. Comparar las soluciones con y sin restricciones

### Plantilla de código

```julia
using JuMP
using Gurobi
using CSV, DataFrames

function leer_datos_csv(ruta_archivo)
    """
    Función para leer los datos del archivo CSV
    Devuelve:
    - df: DataFrame con los datos completos
    - cost: Matriz de costos (n×n)
    - trabajadores: Lista de nombres de trabajadores
    """
    # COMPLETAR: Leer el archivo CSV
    
    # COMPLETAR: Extraer matriz de costos y nombres
    
    return df, cost, trabajadores
end

function modelo_asignacion_basico(cost, trabajadores)
    """
    Implementa el modelo básico de asignación sin restricciones adicionales
    """
    n = size(cost, 1)
    model = Model(Gurobi.Optimizer)
    
    # COMPLETAR: Definir variables binarias
    
    # COMPLETAR: Restricciones de asignación
    
    # COMPLETAR: Función objetivo
    
    optimize!(model)
    
    if termination_status(model) == MOI.OPTIMAL
        println("\nSolución óptima encontrada (sin restricciones adicionales):")
        println("Costo total mínimo: ", objective_value(model))
        println("\nAsignaciones:")
        # COMPLETAR: Mostrar asignaciones óptimas
    else
        println("No se encontró solución óptima.")
    end
    
    return model
end

function modelo_con_restriccion(cost, trabajadores, restricciones)
    """
    Implementa el modelo con restricciones adicionales
    restricciones: Diccionario con pares (i,j) a prohibir
    """
    n = size(cost, 1)
    model = Model(Gurobi.Optimizer)
    
    # COMPLETAR: Definir variables binarias
    
    # COMPLETAR: Restricciones de asignación básicas
    
    # COMPLETAR: Añadir restricciones adicionales
    
    # COMPLETAR: Función objetivo
    
    optimize!(model)
    
    if termination_status(model) == MOI.OPTIMAL
        println("\nSolución óptima encontrada (con restricciones adicionales):")
        println("Costo total mínimo: ", objective_value(model))
        println("\nAsignaciones:")
        # COMPLETAR: Mostrar asignaciones óptimas
    else
        println("No se encontró solución óptima con las restricciones dadas.")
    end
    
    return model
end

function main()
    # Leer datos
    df, cost, trabajadores = leer_datos_csv("datos.csv")
    
    # Resolver modelo básico
    modelo_basico = modelo_asignacion_basico(cost, trabajadores)
    
    # Resolver modelo con restricción adicional
    restricciones = Dict((1,5) => 0)  # Salvador no puede hacer Tarea 5
    modelo_restringido = modelo_con_restriccion(cost, trabajadores, restricciones)
    
    # Comparación de resultados
    if termination_status(modelo_basico) == MOI.OPTIMAL && 
       termination_status(modelo_restringido) == MOI.OPTIMAL
        
        println("\nComparación de resultados:")
        println("Costo sin restricciones: ", objective_value(modelo_basico))
        println("Costo con restricciones: ", objective_value(modelo_restringido))
        println("Diferencia: ", objective_value(modelo_restringido) - objective_value(modelo_basico))
    end
end

# Ejecutar el programa
main()
```

## Ejercicio 3: Problema de Empaquetamiento (Bin Packing)

### Objetivo
Implementar un problema de optimización combinatoria diferente para practicar la modelización con JuMP.

### Problema: Bin Packing
Se tienen n objetos con pesos w₁, w₂, ..., wₙ que deben ser empaquetados en contenedores de capacidad C. El objetivo es minimizar el número de contenedores utilizados.

### Datos del problema
- n = 15 objetos
- Pesos (w): [7, 9, 5, 8, 4, 6, 3, 10, 5, 7, 6, 4, 8, 3, 9]
- Capacidad por contenedor (C): 20

### Tareas
1. Formular el problema matemáticamente
2. Implementar el modelo en JuMP
3. Resolver e interpretar la solución: ¿cuántos contenedores se necesitan y qué objetos van en cada uno?
4. Modificar el problema para incluir una restricción adicional: Algunos objetos no pueden ir en el mismo contenedor (por ejemplo, los objetos 1 y 5 son incompatibles)

### Plantilla de código

```julia
using JuMP
using Gurobi 

function modelo_original()
    """
    Implementa el modelo de Bin Packing 
    """
    # Datos
    n = 15  # Número de objetos
    weights = [7, 9, 5, 8, 4, 6, 3, 10, 5, 7, 6, 4, 8, 3, 9]  # Pesos
    capacity = 20  # Capacidad de cada contenedor
    m = n  # Número máximo de contenedores (peor caso: un objeto por contenedor)

    # Crear modelo
    model = Model(Gurobi.Optimizer)

    # Definir variables
    # COMPLETAR: Definir variables para asignar objetos a contenedores
    # COMPLETAR: Definir variables para indicar qué contenedores se utilizan

    # Definir restricciones
    # COMPLETAR: Cada objeto debe asignarse a exactamente un contenedor
    # COMPLETAR: No exceder la capacidad de cada contenedor
    # COMPLETAR: Un contenedor se considera utilizado si al menos un objeto se le asigna

    # Definir función objetivo
    # COMPLETAR: Minimizar el número de contenedores utilizados

    # Resolver el modelo
    optimize!(model)

    # Verificar estatus e imprimir solución
    if termination_status(model) == MOI.OPTIMAL
        println("Solución óptima encontrada:")
        # COMPLETAR: Imprimir el número de contenedores utilizados
        # COMPLETAR: Imprimir qué objetos van en cada contenedor
    else
        println("No se encontró solución óptima. Estado: ", termination_status(model))
    end
end

function modelo_modificado()
    """
    Implementa el modelo de Bin Packing con restricciones adicionales
    """
    # Datos
    n = 15  # Número de objetos
    weights = [7, 9, 5, 8, 4, 6, 3, 10, 5, 7, 6, 4, 8, 3, 9]  # Pesos
    capacity = 20  # Capacidad de cada contenedor
    m = n  # Número máximo de contenedores (peor caso: un objeto por contenedor)

    # Crear modelo
    model = Model(Gurobi.Optimizer)

    # Definir variables
    # COMPLETAR: Definir variables para asignar objetos a contenedores
    # COMPLETAR: Definir variables para indicar qué contenedores se utilizan

    # Definir restricciones
    # COMPLETAR: Cada objeto debe asignarse a exactamente un contenedor
    # COMPLETAR: No exceder la capacidad de cada contenedor
    # COMPLETAR: Un contenedor se considera utilizado si al menos un objeto se le asigna
    # COMPLETAR: Objetos 1 y 5 no pueden ir en el mismo contenedor

    # Definir función objetivo
    # COMPLETAR: Minimizar el número de contenedores utilizados

    # Resolver el modelo
    optimize!(model)

    # Verificar estatus e imprimir solución
    if termination_status(model) == MOI.OPTIMAL
        println("Solución óptima encontrada:")
        # COMPLETAR: Imprimir el número de contenedores utilizados
        # COMPLETAR: Imprimir qué objetos van en cada contenedor
    else
        println("No se encontró solución óptima. Estado: ", termination_status(model))
    end
end

function main()
    modelo_original()
    modelo_modificado()
end
main()
```

---

## Soluciones

Las soluciones a estos ejercicios se proporcionarán durante el taller o se compartirán posteriormente en el repositorio de materiales.