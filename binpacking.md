# Modelos de Bin Packing con Gurobi y Julia
#### IV EPIO Eduardo Salazar Treviño

## Modelo Original de Bin Packing

Este modelo implementa el problema clásico de bin packing donde se busca minimizar el número de contenedores utilizados para empacar todos los elementos.

$$
\begin{aligned}
\min \quad & \sum_{j=1}^{m} y_j \\
\text{s.a.} \quad & \sum_{j=1}^{m} x_{ij} = 1 \quad \forall i \in \{1,2,\ldots,n\} \\
& \sum_{i=1}^{n} w_i x_{ij} \leq C y_j \quad \forall j \in \{1,2,\ldots,m\} \\
& x_{ij} \leq y_j \quad \forall i \in \{1,2,\ldots,n\}, \forall j \in \{1,2,\ldots,m\} \\
& y_j \leq y_{j-1} \quad \forall j \in \{2,3,\ldots,m\} \\
& x_{ij} \in \{0,1\} \quad \forall i \in \{1,2,\ldots,n\}, \forall j \in \{1,2,\ldots,m\} \\
& y_j \in \{0,1\} \quad \forall j \in \{1,2,\ldots,m\}
\end{aligned}
$$

Donde:

- $w_i$ representa el peso del elemento $i$

- $C$ es la capacidad de cada contenedor

- $x_{ij}$ es una variable binaria que vale 1 si el elemento $i$ es asignado al contenedor $j$, y 0 en caso contrario

- $y_j$ es una variable binaria que vale 1 si el contenedor $j$ es utilizado, y 0 en caso contrario

Restricciones:

- La primera restricción asegura que cada elemento sea asignado exactamente a un contenedor

- La segunda restricción garantiza que la suma de los pesos de los elementos asignados a un contenedor no exceda su capacidad

- La tercera restricción establece que un elemento solo puede ser asignado a un contenedor si este está siendo utilizado

- La cuarta restricción es de simetría y asegura que los contenedores se utilicen en orden

## Modelo Modificado con Restricción de Incompatibilidad

Este modelo extiende el problema básico de bin packing añadiendo una restricción que prohíbe colocar ciertos elementos en el mismo contenedor.

$$
\begin{aligned}
\min \quad & \sum_{j=1}^{m} y_j \\
\text{s.a.} \quad & \sum_{j=1}^{m} x_{ij} = 1 \quad \forall i \in \{1,2,\ldots,n\} \\
& \sum_{i=1}^{n} w_i x_{ij} \leq C y_j \quad \forall j \in \{1,2,\ldots,m\} \\
& x_{ij} \leq y_j \quad \forall i \in \{1,2,\ldots,n\}, \forall j \in \{1,2,\ldots,m\} \\
& y_j \leq y_{j-1} \quad \forall j \in \{2,3,\ldots,m\} \\
& x_{1j} + x_{5j} \leq 1 \quad \forall j \in \{1,2,\ldots,m\} \\
& x_{ij} \in \{0,1\} \quad \forall i \in \{1,2,\ldots,n\}, \forall j \in \{1,2,\ldots,m\} \\
& y_j \in \{0,1\} \quad \forall j \in \{1,2,\ldots,m\}
\end{aligned}
$$

Donde:

- La restricción adicional $x_{1j} + x_{5j} \leq 1$ impide que los elementos 1 y 5 sean colocados en el mismo contenedor $j$