# Modelos de Asignación con Gurobi y Julia
#### IV EPIO Eduardo Salazar Treviño

## Modelo de Asignación Básico

Este modelo implementa un problema de asignación clásico donde se minimizan los costos de asignar trabajadores a tareas.

$$
\begin{aligned}
\min \quad & \sum_{i=1}^{n} \sum_{j=1}^{n} c_{ij} x_{ij} \\
\text{s.a.} \quad & \sum_{j=1}^{n} x_{ij} = 1 \quad \forall i \in \{1,2,\ldots,n\} \\
& \sum_{i=1}^{n} x_{ij} = 1 \quad \forall j \in \{1,2,\ldots,n\} \\
& x_{ij} \in \{0,1\} \quad \forall i,j \in \{1,2,\ldots,n\}
\end{aligned}
$$

Donde:

- $c_{ij}$ representa el costo de asignar el trabajador $i$ a la tarea $j$

- $x_{ij}$ es una variable binaria que vale 1 si el trabajador $i$ es asignado a la tarea $j$, y 0 en caso contrario

- La primera restricción asegura que cada trabajador sea asignado exactamente a una tarea

- La segunda restricción asegura que cada tarea sea asignada exactamente a un trabajador

## Modelo con Restricciones Adicionales

Este modelo extiende el problema de asignación básico añadiendo restricciones que prohíben ciertas asignaciones específicas.

$$
\begin{aligned}
\min \quad & \sum_{i=1}^{n} \sum_{j=1}^{n} c_{ij} y_{ij} \\
\text{s.a.} \quad & \sum_{j=1}^{n} y_{ij} = 1 \quad \forall i \in \{1,2,\ldots,n\} \\
& \sum_{i=1}^{n} y_{ij} = 1 \quad \forall j \in \{1,2,\ldots,n\} \\
& y_{ij} = 0 \quad \forall (i,j) \in R \\
& y_{ij} \in \{0,1\} \quad \forall i,j \in \{1,2,\ldots,n\}
\end{aligned}
$$

Donde:

- $c_{ij}$ representa el costo de asignar el trabajador $i$ a la tarea $j$

- $y_{ij}$ es una variable binaria que vale 1 si el trabajador $i$ es asignado a la tarea $j$, y 0 en caso contrario

- $R$ es el conjunto de pares $(i,j)$ que representan asignaciones prohibidas

- La tercera restricción impide explícitamente que ciertas asignaciones ocurran