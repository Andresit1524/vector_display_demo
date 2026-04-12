class_name Arrow2D extends CharacterBody2D


# Coulomb's Law (modified)
var K := 9 * (10 ** 6)


var force: Vector2


func _physics_process(_delta) -> void:
	# Calculates force using Coulombs's law
	var delta_pos := (global_position - get_global_mouse_position())
	var director := delta_pos.normalized()
	var distance := delta_pos.length()

	# Force is read from Vector Display
	force = director * (K / distance ** 2)
