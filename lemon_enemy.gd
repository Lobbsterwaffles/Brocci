extends Enemy

@export var extrapolate = 1

func _ready():
	super()
	

func _physics_process(delta):
	var pt = ref_player.position + extrapolate * ref_player.velocity
	%marker.global_position = pt
	velocity = speed * 60 * delta * position.direction_to(pt)
	move_and_slide()
