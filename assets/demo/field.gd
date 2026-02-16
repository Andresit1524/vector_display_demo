extends Node

@export var field_step: float = 20.0

var arrow_scene := preload("uid://c6tr3lnbx3704")
var viewport: Viewport
var last_camera_transform: Transform2D
var boundaries: Dictionary[String, Vector2] = {
	"top_left": Vector2.ZERO,
	"bottom_right": Vector2.ZERO,
}

func _ready() -> void:
	# Inicializa el viewport y su movimiento
	viewport = get_viewport()
	last_camera_transform = viewport.get_canvas_transform()
	_reset_field()

func _process(_delta) -> void:
	# Verifica el movimiento del viewport y re-renderiza el campo
	var current_transform := viewport.get_canvas_transform()
	if current_transform != last_camera_transform:
		last_camera_transform = current_transform
		_reset_field()

## Elimina o regenera el campo eléctrico de la pantalla
func toggle_field(activate: bool) -> void:
	if activate:
		_get_global_viewport_corners()
		_instantiate_field()
		return

	for arrow in get_children():
		arrow.queue_free()

## Determina la posición del viewport en el mundo
func _get_global_viewport_corners() -> void:
	var rect_visible = viewport.get_visible_rect()

	# Obtenemos la transformación inversa (Pantalla -> Mundo)
	var transform_inversa = viewport.get_canvas_transform().affine_inverse()

	# Calculamos las 4 esquinas multiplicando la transformación por los puntos
	boundaries.top_left = transform_inversa * rect_visible.position
	boundaries.bottom_right = transform_inversa * (rect_visible.position + rect_visible.size)

## Instancia las flechas del campo eléctrico a lo largo de una cuadrícula
func _instantiate_field() -> void:
	var arrow_coordinates: Array[Vector2]
	var current_point := boundaries.top_left

	# Recorre todo el espacio de la camara
	while true:
		arrow_coordinates.append(current_point)

		current_point.x += field_step

		if current_point.x > boundaries.bottom_right.x:
			current_point.x = boundaries.top_left.x
			current_point.y += field_step

		if current_point.y > boundaries.bottom_right.y:
			break

	for point in arrow_coordinates:
		var arrow = arrow_scene.instantiate()
		arrow.position = point
		add_child(arrow)

## Resetea el campo
func _reset_field() -> void:
	toggle_field(false)
	toggle_field(true)
