extends Camera3D

@export var speed = 2

var direction := {
	"movement": 0,
	"rotation": 0,
}

func _process(delta):
	direction.movement = Input.get_axis("left", "right")
	direction.rotation = - Input.get_axis("rot_left", "rot_right")

	rotation.y += direction.rotation * speed * delta
	position.x += direction.movement * speed * delta
