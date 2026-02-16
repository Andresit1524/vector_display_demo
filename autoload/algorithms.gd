extends Node

## Calcula la fuerza neta de las cargas siguiendo la ley de Coulomb[br]
## - [code]position[/code] contiene la posicion el objeto actual[br]
## - [code]value[/code] es la carga del objeto actual
func net_electric_force(charge_node: Node2D, position: Vector2, value: int = 1) -> Vector2:
	var net_force: Vector2 = Vector2.ZERO

	for charge in get_tree().get_nodes_in_group("charges"):
		# Nos omitimos a nosotros mismos
		if charge == charge_node:
			continue

		var direction: Vector2 = position - charge.position
		var distance_px: float = direction.length()

		# Convertir distancia a metros según la escala
		var distance_m: float = distance_px / Constants.WORLD_SCALE
		var dir_vector: Vector2 = direction.normalized()

		# Ley de Coulomb simplificada: F = (q1 * q2) / r^2
		var force_magnitude = (value * charge.value) / (distance_m ** 2)

		net_force += dir_vector * force_magnitude

	return net_force