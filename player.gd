extends CharacterBody2D

@export var health_max = 100
@export var speed = 290
@export var dmg_mult = 1.0

signal shoot()
signal hit(dmg)

var health = health_max

@onready var ref_health_bar = get_node("/root/Rootly/ui/hud/health_bar")
@onready var ref_health_lbl = get_node("/root/Rootly/ui/hud/health_lbl")

func _ready():
	motion_mode = MotionMode.MOTION_MODE_FLOATING

func get_input():
	velocity = speed * Input.get_vector("a", "d", "w", "s")
	if not velocity.is_zero_approx():
		rotation = atan2(velocity.y, velocity.x)

	if Input.is_action_just_pressed("e"):
		shoot.emit()

	
func _physics_process(delta):
	get_input()
	move_and_slide()

func _process(delta):
	ref_health_bar.max_value = health_max
	ref_health_bar.value = health
	ref_health_lbl.text = "HP: %d" % [health as int]

func take_damage(dmg):
	health -= dmg
	
