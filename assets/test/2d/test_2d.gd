extends Node2D


@export var preset: VectorDisplaySettings
@export var distance: float = 100.0


func _ready() -> void:
	# Delete all current arrows
	for child in get_children():
		if is_instance_of(child, Arrow2D): remove_child(child)

	# Add arrows along a grid
	for i in range(0, 1500, distance):
		for j in range(0, 750, distance):
			var pos := Vector2(i, j)

			# Create arrow
			var new_arrow := Arrow2D.new()
			new_arrow.global_position = pos

			# Create vector display
			var display_node := VectorDisplay2D.new()
			new_arrow.add_child(display_node)

			# Configure vector display
			display_node.settings = preset
			display_node.target_node = new_arrow
			display_node.target_property = "force"
			display_node.settings.max_length = distance

			add_child(new_arrow)
