# Modelos de Programación Lineal con Gurobi y Julia
#### IV EPIO Eduardo Salazar

## Modelo Original

Este modelo implementa la formulación básica de programación lineal para el problema de producción de bebidas.

$$
\begin{aligned}
\max \quad & 3x_1 + 2x_2 \\
\text{s.a.} \quad & 5x_1 + 6x_2 \leq 60 \quad \text{(Restricción de agua)} \\
& 2x_1 + x_2 \leq 15 \quad \text{(Restricción de concentrado)} \\
& x_1, x_2 \geq 0
\end{aligned}
$$

Donde:
- $x_1$ representa los litros de Bebida Regular
- $x_2$ representa los litros de Bebida Light

## Modelo con Beneficio Modificado para Bebida Light

Este modelo modifica el beneficio asociado a la Bebida Light.

$$
\begin{aligned}
\max \quad & 3x_1 + 2.5x_2 \\
\text{s.a.} \quad & 5x_1 + 6x_2 \leq 60 \quad \text{(Restricción de agua)} \\
& 2x_1 + x_2 \leq 15 \quad \text{(Restricción de concentrado)} \\
& x_1, x_2 \geq 0
\end{aligned}
$$

## Modelo con Aumento de Concentrado Disponible

Este modelo considera un incremento en la disponibilidad del concentrado.

$$
\begin{aligned}
\max \quad & 3x_1 + 2x_2 \\
\text{s.a.} \quad & 5x_1 + 6x_2 \leq 60 \quad \text{(Restricción de agua)} \\
& 2x_1 + x_2 \leq 20 \quad \text{(Restricción de concentrado aumentado)} \\
& x_1, x_2 \geq 0
\end{aligned}
$$