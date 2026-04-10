extends CharacterBody2D
@export var speed = 290
@export var health_max = 100

signal shoot()
signal hit(dmg)

func _ready():
	motion_mode = MotionMode.MOTION_MODE_FLOATING

func get_input():
	velocity = speed * Input.get_vector("a", "d", "w", "s")
	if not velocity.is_zero_approx():
		rotation = atan2(velocity.y, velocity.x)

	if Input.is_action_just_pressed("e"):
		shoot.emit()

func hurt(dmg):
	print("Ow %s" % [dmg])
	
func _physics_process(delta):
	get_input()
	move_and_slide()

	
	
