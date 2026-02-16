extends CharacterBody2D

enum Signs {
	POSITIVE = 1,
	NEGATIVE = -1
}

@export_group("Particle")
@export var charge_sign: Signs = Signs.NEGATIVE ## Signo de la carga
@export var value: int = 1 ## Intensidad de la carga

@export_group("Behaviour")
@export var unmovable: bool = false ## Fija el objeto en el mundo
@export var point_to_mouse: bool = false ## Las cargas se ven atraidas por el mouse
@export var apply_friction: bool = false ## Aplica fricción al desplazamiento

@export_group("Show")
@export var show_value: bool = true: ## Muestra el valor de la carga arriba de él
	set(value):
		show_value = value
		if value_label: value_label.visible = value
@export var show_force: bool = true: ## Muestra la fuerza neta de la carga como un segmento
	set(value):
		show_force = value
		if vector_display: vector_display.show_vectors = value
@export var show_axes: bool = false: ## Muestra los componentes en X y Y de la fuerza
	set(value):
		show_axes = value
		if vector_display: vector_display.show_axes = value

@onready var value_label := $Value
@onready var vector_display := $VectorDisplay2D

var force: Vector2

func _ready() -> void:
	if show_value:
		value_label.text = str(value)
	else:
		value_label.visible = false

	vector_display.show_vectors = show_force
	vector_display.show_axes = show_axes

	# Configura la carga y el color
	value *= charge_sign
	$Sprite.modulate = Color.RED if charge_sign == Signs.POSITIVE else Color.BLUE

func _physics_process(delta: float) -> void:
	force = Algorithms.net_electric_force(self , position, value)

	if point_to_mouse:
		var direction := (get_global_mouse_position() - global_position).normalized()
		force += direction * 100 # Fuerza de atracción arbitraria

	if unmovable: return

	velocity += force * delta
	if apply_friction: velocity *= Constants.FRICTION
	move_and_slide()
