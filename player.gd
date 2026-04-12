extends CharacterBody2D

@export var health_max = 100
@export var speed = 290
@export var dmg_mult = 1.0

var hearts = 0
var cabbage = 0
var lightning = 0

signal shoot()
signal hit(dmg)

var health = health_max

@onready var ref_health_bar = get_node("/root/Rootly/ui/hud/health_bar")
@onready var ref_health_lbl = get_node("/root/Rootly/ui/hud/health_lbl")

@onready var ref_heart_lbl = get_node("/root/Rootly/ui/hud/%lbl_player_heart")
@onready var ref_cabbage_lbl = get_node("/root/Rootly/ui/hud/%lbl_player_cabbage")
@onready var ref_lightning_lbl = get_node("/root/Rootly/ui/hud/%lbl_player_lightning")



func _ready():
	motion_mode = MotionMode.MOTION_MODE_FLOATING

func get_input():
	velocity = speed * Input.get_vector("a", "d", "w", "s")
	# if not velocity.is_zero_approx():
	# 	%flipper.scale.x = sign(velocity.x)
	if velocity.x < 0:
		%flipper.scale.x = -1
	elif velocity.x > 0:
		%flipper.scale.x = 1
		
	if Input.is_action_just_pressed("e"):
		shoot.emit()

	
func _physics_process(delta):
	get_input()
	move_and_slide()

func _process(delta):
	ref_health_bar.max_value = health_max
	ref_health_bar.value = health
	ref_health_lbl.text = "HP: %d" % [health as int]
	ref_heart_lbl.text = "%d" % [hearts]
	ref_cabbage_lbl.text = "%d" % [cabbage]
	ref_lightning_lbl.text = "%d" % [lightning]

	if velocity.is_zero_approx():
		%sprite.pause()
		%sprite.frame = 0
	else:
		%sprite.play()
				

func take_damage(dmg):
	health -= dmg
	
func gain_hearts(x):
	hearts += x
func gain_cabbage(x):
	cabbage += x
func gain_lightning(x):
	lightning += x
