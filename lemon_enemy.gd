extends Enemy

@export var extrapolate = 1

func _physics_process(delta):
	var pt = ref_player.position + extrapolate * ref_player.velocity
	%marker.global_position = pt
	velocity = speed * position.direction_to(pt)
	move_and_slide()
