class_name Enemy
extends CharacterBody2D

@export var health_max = 100
@export var speed = 100 # can't be called speed ???????????
@export var player_dmg = 20

var health
var hitting_player = false

@onready var ref_player = get_node("/root/Rootly/Player")
@onready var ref_timer = $player_hit_timer

func _ready():
	health = health_max
	%healthbar.value = health / health_max
	%Hurt.area_entered.connect(hurt_enter)
	$Hit.area_entered.connect(hit_enter)
	$Hit.area_exited.connect(hit_exit)
	ref_timer.timeout.connect(damage_player)

func hurt_enter(area):
	var b = area as Bullet
	if not b:
		return
	health -= b.damage * ref_player.dmg_mult
	%healthbar.value = health as float / health_max
	b.on_hit()
	if health <= 0:
		print("I die")
		queue_free()

func hit_enter(area):
	var h = area as PlayerHurtbox
	if not h:
		return
	assert(ref_timer.is_stopped())
	ref_timer.start()

func hit_exit(area):
	var h = area as PlayerHurtbox
	if not h:
		return
	ref_timer.stop()
	
func _physics_process(delta):
	velocity = speed * position.direction_to(ref_player.position)
	move_and_slide()

func damage_player():
	ref_player.take_damage(player_dmg)
