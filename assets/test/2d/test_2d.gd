extends Node2D


# Coulomb's Law (modified)
var K := 9 * (10 ** 6)


@export var preset: VectorDisplaySettings
@export var distance: float = 100.0


var pos_list: Array[Vector2] = []
var arrow_list: Array[Vector2] = []


func _ready() -> void:
	# Create and configure Vector Display
	var vd := VectorDisplay2D.new()
	vd.settings = preset
	add_child(vd)

	vd.target_node = self
	vd.target_property = "arrow_list"
	vd.target_position_property = "pos_list"


func _physics_process(_delta) -> void:
	# Limpiamos las listas para que no se acumulen vectores de frames anteriores
	pos_list.clear()
	arrow_list.clear()

	# Add arrows along a grid
	for i in range(0, 1500, distance):
		for j in range(0, 750, distance):
			var pos := Vector2(i, j)
			var force := calculate_force(pos)

			pos_list.append(pos)
			arrow_list.append(force)


func calculate_force(current_pos: Vector2) -> Vector2:
	# Calculates force using Coulombs's law
	var delta_pos := (current_pos - get_global_mouse_position())
	var director := delta_pos.normalized()
	var _distance := delta_pos.length()

	# Force is read from Vector Display
	return director * (K / _distance ** 2)
