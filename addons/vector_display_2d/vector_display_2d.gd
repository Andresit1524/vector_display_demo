class_name VectorDisplay2D extends Node2D


## Node to show its vectors
@export var target_node: Node
## Name of the Vector2 attribute or variable in node's script
@export var target_property: StringName = &"velocity"
## Optional: Name of the property that holds the origins (Vector2 or Array)
@export var target_position_property: StringName = &""
## Vector display settings. Create your own using a [code]VectorDisplaySettings[/code] resource
@export var settings: VectorDisplaySettings


# Auxiliary variables
var _line_points := PackedVector2Array()
var _line_colors := PackedColorArray()
var _arrow_points := PackedVector2Array()
var _arrow_colors := PackedColorArray()
var _last_input_hash: int = 0


#region Node life cycle


# Reassigns the target node or throws error when it doesn't exists
func _ready() -> void:
	VectorDisplayFunctions.check_targets_and_settings(self, target_node, target_property, settings)

	# Redraw automatically when settings change
	settings.changed.connect(queue_redraw)


# Get and process the vector from given property
func _process(_delta) -> void:
	if not is_instance_valid(target_node): return

	# New values
	var raw_input = target_node.get(target_property)
	if raw_input == null: return

	# Simple hash check to avoid redundant calculations
	var current_hash = hash(raw_input)
	if not target_position_property.is_empty():
		current_hash += hash(target_node.get(target_position_property))

	if _last_input_hash == current_hash: return
	_last_input_hash = current_hash

	var raw_offsets = null
	if not target_position_property.is_empty():
		raw_offsets = target_node.get(target_position_property)

	# Normalizes input to always be a list for processing
	var input_list: Array = []
	if raw_input is Vector2: input_list = [raw_input]
	elif raw_input is Array or raw_input is PackedVector2Array: input_list = Array(raw_input)
	else: return

	# Normalizes offsets
	var offset_list: Array = []
	if raw_offsets is Vector2: offset_list = [raw_offsets]
	elif raw_offsets is Array or raw_offsets is PackedVector2Array: offset_list = Array(raw_offsets)

	# Prepare batch arrays
	var new_line_points := PackedVector2Array()
	var new_line_colors := PackedColorArray()
	var new_arrow_points := PackedVector2Array()
	var new_arrow_colors := PackedColorArray()

	for i in range(input_list.size()):
		var raw_v: Vector2 = input_list[i]
		var offset: Vector2 = offset_list[i] if i < offset_list.size() else Vector2.ZERO

		var processed_v = VectorDisplayFunctions.apply_length_mode(raw_v, settings)
		var colors = VectorDisplayFunctions.calculate_draw_colors(processed_v, raw_v.length(), settings)
		var pos = VectorDisplayFunctions.get_main_vector_position(processed_v, settings)

		# Add main line
		new_line_points.push_back(pos.begin + offset)
		new_line_points.push_back(pos.end + offset)
		new_line_colors.push_back(colors.main)

		# Pre-calculate arrowhead if needed
		if settings.arrowhead:
			_append_arrowhead_points(new_arrow_points, new_arrow_colors, pos.begin + offset, pos.end + offset, colors.main)

		# Axes
		if settings.show_axes:
			var axes_pos = VectorDisplayFunctions.get_axes_positions(processed_v, settings)
			new_line_points.push_back(axes_pos.x_begin + offset)
			new_line_points.push_back(axes_pos.x_end + offset)
			new_line_colors.push_back(colors.x)
			new_line_points.push_back(axes_pos.y_begin + offset)
			new_line_points.push_back(axes_pos.y_end + offset)
			new_line_colors.push_back(colors.y)
			if settings.arrowhead:
				_append_arrowhead_points(new_arrow_points, new_arrow_colors, axes_pos.x_begin + offset, axes_pos.x_end + offset, colors.x)
				_append_arrowhead_points(new_arrow_points, new_arrow_colors, axes_pos.y_begin + offset, axes_pos.y_end + offset, colors.y)

	_line_points = new_line_points
	_line_colors = new_line_colors
	_arrow_points = new_arrow_points
	_arrow_colors = new_arrow_colors
	queue_redraw()


#endregion


#region Draw functions


# Draw the vectors
func _draw() -> void:
	if not settings.show_vectors: return

	if _line_points.size() > 1:
		draw_multiline_colors(_line_points, _line_colors, settings.width, true)

	# Draw all arrowheads in one batch if possible
	# Note: draw_multiline for wireframe or RenderingServer for filled triangles
	for i in range(0, _arrow_points.size(), 3):
		draw_polygon([_arrow_points[i], _arrow_points[i + 1], _arrow_points[i + 2]], [_arrow_colors[i / 3]])


## Internal helper to calculate arrowhead vertices and append them to batch arrays
func _append_arrowhead_points(points: PackedVector2Array, colors: PackedColorArray, start: Vector2, position: Vector2, color: Color) -> void:
	var director := (position - start).normalized()
	var actual_size := settings.width * settings.arrowhead_size * 2
	var offset := director * settings.width * settings.arrowhead_size
	if offset.length() > (position - start).length(): return

	var actual_position := position + offset
	points.push_back(actual_position)
	points.push_back(actual_position - director.rotated(PI / 6) * actual_size)
	points.push_back(actual_position - director.rotated(-PI / 6) * actual_size)
	colors.push_back(color)


#endregion


#region Input functions


# Detects shortcut to toggle visibility. Avoid concurrency and echo errors
func _unhandled_key_input(event: InputEvent) -> void:
	if VectorDisplayFunctions.check_shortcut(event, settings):
		get_viewport().set_input_as_handled()


#endregion
