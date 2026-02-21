extends CharacterBody2D

var force: Vector2

func _process(delta):
	force = (get_global_mouse_position() - global_position)
	velocity = force * delta * 20
	move_and_slide()
