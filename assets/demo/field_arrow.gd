extends Node2D

@export var point_to_mouse: bool = false ## Las cargas se ven atraidas por el mouse

var force: Vector2

func _process(_delta):
	force = Algorithms.net_electric_force(self , position)

	if point_to_mouse:
		var direction := (get_global_mouse_position() - global_position).normalized()
		force += direction * 100 # Fuerza de atracción arbitraria
