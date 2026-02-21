@icon("res://assets/test/vector_display_3d/icon_3d.svg")
extends Node3D

const SHORTCUT: InputEventKey = preload("res://addons/vector_display_2d/display_shortcut.tres")
const DIMMING_SPEED_CORRECTION := 10

@export_group("Node")
@export var target_node: Node: ## Node to show its vectors
	set(value):
		target_node = value
		_draw_vector()
@export var target_property: String = "velocity": ## Name of the Vector3 attribute or variable in node's script
	set(value):
		target_property = value
		_draw_vector()

@export_group("Show")
@export var show_vectors: bool = true: ## Show or hide all
	set(value):
		show_vectors = value
		_draw_vector()
@export var show_axes: bool = false: ## Shows X, Y and Z component for the vector
	set(value):
		show_axes = value
		_draw_vector()

@export_group("Rendering")
@export_range(0.05, 100, 0.05, "exp", "or_greater") var vector_scale: float = 1: ## Change vectors size. This doesn't change the actual vector values
	set(value):
		vector_scale = value
		_draw_vector()
@export_range(0.1, 10, 0.1, "exp", "or_greater") var width: float = 1: ## Line width
	set(value):
		width = value
		_draw_vector()
@export var clamp_vector: bool = false: ## Clamp the vector length to a max value defined below. This doesn't change the actual vector values
	set(value):
		clamp_vector = value
		_draw_vector()
@export var normalize: bool = false: ## Normalize vector length to max length defined below. This doesn't change the actual vector values
	set(value):
		normalize = value
		_draw_vector()
@export_range(0.1, 1000, 0.1, "exp", "or_greater") var max_length: float = 100: ## Max length for vector clamping or normalizing
	set(value):
		max_length = value
		_draw_vector()
@export var decorator: bool = true: ## Add a decoration for vectors head. Is always a triangle
	set(value):
		decorator = value
		_draw_vector()
@export_enum("Normal", "Centered") var pivot_mode: String = "Normal": ## Change the pivot point. Normal: starts from origin. Centered: scales symmetrically
	set(value):
		pivot_mode = value
		_draw_vector()
@export_enum("Same", "Normal", "Centered") var axis_pivot_mode: String = "Same": ## Keep same pivot point for axes or override them. Highly recommended to keep in "Same"
	set(value):
		axis_pivot_mode = value
		_draw_vector()

@export_group("Colors")
@export var main_color: Color = Color.YELLOW: ## Color for main_mesh vector
	set(value):
		main_color = value
		_draw_vector()
@export var x_axis_color: Color = Color.RED: ## Color for X component of vector
	set(value):
		x_axis_color = value
		_draw_vector()
@export var y_axis_color: Color = Color.GREEN: ## Color for Y component of vector
	set(value):
		y_axis_color = value
		_draw_vector()
@export var z_axis_color: Color = Color.BLUE: ## Color for Y component of vector
	set(value):
		z_axis_color = value
		_draw_vector()
# @export var rainbow: bool = false: ## Change main_mesh vector color based on the its angle. Not aplies for axes
# 	set(value):
# 		rainbow = value
# 		_draw_vector()

@export_group("Color dimming")
@export var dimming: bool = false: ## Turns the vector color to a fallback one when the vector gets short
	set(value):
		dimming = value
		_draw_vector()
@export_range(0.01, 10, 0.01, "or_greater") var dimming_speed: float = 1: ## Dimming speed for all colors
	set(value):
		dimming_speed = value
		_draw_vector()
@export var fallback_color: Color = Color.BLACK: ## Color the vectors tend to when they get short
	set(value):
		fallback_color = value
		_draw_vector()
@export var dimming_if_normalized: bool = false: ## Apply dimming even when vectors are normalized
	set(value):
		dimming_if_normalized = value
		_draw_vector()
@export_enum("Absolute", "Visual") var normalized_dimming_type: String = "Absolute": ## Apply dimming based on actual value (with scale) of vector or visual length
	set(value):
		normalized_dimming_type = value
		_draw_vector()

# Auxiliar variables
var current_vector := Vector3.ZERO
var current_raw_length := 0.0
var cylinder_instance: MeshInstance3D
var main_mesh: CylinderMesh
var material := StandardMaterial3D.new()

func _ready() -> void:
	if target_node == null:
		push_warning("Target node not defined. Autoassigning to parent node")
		target_node = get_parent()

	if not target_node:
		push_error("Parent node not found")
		return

	if not target_node.get(target_property) is Vector3:
		push_error("Target property is not a Vector3 or doesn't exist")

	_initialize_cylinder()

# Get the vector from given property
func _process(_delta):
	if not is_instance_valid(target_node): return
	var new_vector: Vector3 = target_node.get(target_property) * vector_scale
	var new_raw_length := new_vector.length()

	if normalize: new_vector = new_vector.normalized() * max_length
	if clamp_vector: new_vector = new_vector.limit_length(max_length)

	# Improves performance rendering when necesary
	if current_vector == new_vector and is_equal_approx(current_raw_length, new_raw_length): return

	current_vector = new_vector
	current_raw_length = new_raw_length
	_draw_vector()

## Create cilinder from scratch
func _initialize_cylinder() -> void:
	# Instance and add
	cylinder_instance = MeshInstance3D.new()
	main_mesh = CylinderMesh.new()
	cylinder_instance.mesh = main_mesh
	add_child(cylinder_instance, true)

	# Configure color material
	main_mesh.material = material

	# Optimize
	main_mesh.cap_top = true
	main_mesh.cap_bottom = true
	main_mesh.radial_segments = 6
	main_mesh.rings = 0

# Draw the vectors
func _draw_vector() -> void:
	if not show_vectors: return
	if not main_mesh: return

	var colors := _get_draw_colors()

	# Main vector calculos and render, according to mode
	var current_vector_position := _get_main_vector_position()
	_draw_cylinder(current_vector_position.begin, current_vector_position.end, colors.main_mesh, width)
	_draw_decorators(current_vector_position.end, width * 3, colors.main_mesh)

	if not show_axes: return

	# Axes components calculus, according to mode
	var current_axes_position := _get_axes_position()

	# Axis render
	_draw_cylinder(current_axes_position.x_begin, current_axes_position.x_end, colors.x, width)
	_draw_decorators(current_axes_position.x_end, width * 3, colors.x)
	_draw_cylinder(current_axes_position.y_begin, current_axes_position.y_end, colors.y, width)
	_draw_decorators(current_axes_position.y_end, width * 3, colors.y)

func _draw_cylinder(begin: Vector3, end: Vector3, color: Color, diameter: float) -> void:
	# Dimensions
	main_mesh.top_radius = diameter / 2
	main_mesh.bottom_radius = diameter / 2
	main_mesh.height = (end - begin).length()

	# Orientation
	cylinder_instance.basis = _get_cylinder_rotated_basis(current_vector)
	cylinder_instance.position = (begin + end) / 2

	# Color
	material.albedo_color = color

## Make the rotation basis of given vector. Doesn't matter the XZ orientation since is used for a cylinder
func _get_cylinder_rotated_basis(vector: Vector3):
	# Y is the cylinder base
	var y_basis := vector.normalized()

	# Basis from arbitrary start and cross product
	var x_basis := vector.cross(vector + Vector3(1, 1, 1)).normalized()
	var z_basis := vector.cross(x_basis).normalized()

	return Basis(x_basis, y_basis, z_basis)

## Calculate colors based on current settings (Rainbow, Dimming, etc)
func _get_draw_colors() -> Dictionary:
	var colors := {
		"main_mesh": main_color,
		"x": x_axis_color,
		"y": y_axis_color,
		"z": z_axis_color
	}

	# if rainbow:
	# 	var angle := current_vector.angle()
	# 	if angle < 0: angle += TAU

	# 	colors.main_mesh = Color.from_hsv(angle / TAU, 1.0, 1.0)

	if dimming and (not normalize or dimming_if_normalized):
		var length: float
		match normalized_dimming_type:
			"Absolute": length = current_raw_length
			"Visual": length = current_vector.length()

		var dimming_value := 1.0
		if not is_zero_approx(length):
			dimming_value = clampf(dimming_speed * DIMMING_SPEED_CORRECTION / length, 0.0, 1.0)

		colors.x = colors.x.lerp(fallback_color, dimming_value)
		colors.y = colors.y.lerp(fallback_color, dimming_value)
		colors.z = colors.z.lerp(fallback_color, dimming_value)
		colors.main_mesh = colors.main_mesh.lerp(fallback_color, dimming_value)

	return colors

## Calculate main_mesh vector position based on pivot mode
func _get_main_vector_position() -> Dictionary:
	var main_vector := {
		"begin": Vector3.ZERO,
		"end": Vector3.ZERO
	}

	match pivot_mode:
		"Normal":
			main_vector.begin = Vector3.ZERO
			main_vector.end = current_vector
		"Centered":
			main_vector.begin = - current_vector / 2
			main_vector.end = current_vector / 2

	return main_vector

## Calculates axes position based on pivot modes
func _get_axes_position() -> Dictionary:
	var axes := {
		"x_begin": Vector3.ZERO,
		"x_end": Vector3.ZERO,
		"y_begin": Vector3.ZERO,
		"y_end": Vector3.ZERO,
		"z_begin": Vector3.ZERO,
		"z_end": Vector3.ZERO
	}

	if axis_pivot_mode == "Normal" and pivot_mode == "Centered":
		axes.x_begin = - Vector3(current_vector.x / 2, current_vector.y / 2, current_vector.z / 2)
		axes.x_end = Vector3(current_vector.x / 2, -current_vector.y / 2, -current_vector.z / 2)
		axes.y_begin = - Vector3(current_vector.x / 2, current_vector.y / 2, current_vector.z / 2)
		axes.y_end = Vector3(-current_vector.x / 2, current_vector.y / 2, -current_vector.z / 2)
		axes.z_begin = - Vector3(current_vector.x / 2, current_vector.y / 2, current_vector.z / 2)
		axes.z_end = Vector3(-current_vector.x / 2, -current_vector.y / 2, current_vector.z / 2)
	elif axis_pivot_mode == "Normal" or (pivot_mode == "Normal" and axis_pivot_mode == "Same"):
		axes.x_begin = Vector3.ZERO
		axes.x_end = Vector3(current_vector.x, 0, 0)
		axes.y_begin = Vector3.ZERO
		axes.y_end = Vector3(0, current_vector.y, 0)
		axes.z_begin = Vector3.ZERO
		axes.z_end = Vector3(0, 0, current_vector.z)
	elif axis_pivot_mode == "Centered" or (pivot_mode == "Centered" and axis_pivot_mode == "Same"):
		axes.x_begin = - Vector3(current_vector.x / 2, 0, 0)
		axes.x_end = Vector3(current_vector.x / 2, 0, 0)
		axes.y_begin = - Vector3(0, current_vector.y / 2, 0)
		axes.y_end = Vector3(0, current_vector.y / 2, 0)
		axes.z_begin = - Vector3(0, 0, current_vector.z / 2)
		axes.z_end = Vector3(0, 0, current_vector.z / 2)

	return axes

## Draws decorator for vector, let given position
@warning_ignore("unused_parameter")
func _draw_decorators(decorator_position: Vector3, size: float, color: Color) -> void:
	if not decorator: return

	# TODO: Make ts

# Detects shortcut to toggle visibility
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and event.is_match(SHORTCUT): show_vectors = not show_vectors
