extends CharacterBody2D

@export var health_max = 100
@export var speed2 = 100 # can't be called speed ???????????

var health = health_max  

@onready var ref_player = get_node("/root/Rootly/Player")

func _ready():
	%Hurt.area_entered.connect(hurt_enter)

func hurt_enter(area):
	var b = area as Bullet
	if not b:
		return
	health -= b.damage
	b.queue_free()
	if health <= 0:
		queue_free()
	
	
func _physics_process(delta):
	velocity = speed2 * position.direction_to(ref_player.position)
	move_and_slide()
