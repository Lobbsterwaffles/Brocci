extends Node2D

var scn_enemy = preload("res://enemy.tscn")
var scn_bullet = preload("res://bullet.tscn")
var scn_card = preload("res://card.tscn")

var ref_progress
var ref_cc

var cards = []

var card_def = [
	mkcard("One enemy", "-", "spawn one enemy", func (): spawn_enemy_ring(1)),
	mkcard("Two enemy", "-", "spawn two enemies", func (): spawn_enemy_ring(2)),
	mkcard("A lot", "-", "spawn 20 enemies", func (): spawn_enemy_ring(20)),
]

func mkcard(name, top, bot, effect):
	var c = scn_card.instantiate()
	c.get_node("name").text = "new text"
	c.get_node("toptext").text = "ntop"
	c.get_node("bottext").text = "nbot"
	return c

func spawn_enemy_ring(n):
	for i in range(n):
		var e = scn_enemy.instantiate()
		var angle = 2 * PI * randf()
		var radius = 200 + 20 * randf()
		e.position = %Player.position + radius * Vector2(cos(angle), sin(angle))
		add_child(e)

func _ready():
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	%Player.shoot.connect(_on_player_shoot)
	ref_progress = get_node("%ui/hud/ProgressBar")
	ref_cc = get_node("%ui/hud/card_container")
	print("Refs ", ref_progress, " ", ref_cc)
	var ncard = scn_card.instantiate()
	ncard.get_node("name").text = "new text"
	ncard.get_node("toptext").text = "ntop"
	ncard.get_node("bottext").text = "nbot"
	
	ref_cc.add_child(ncard)
	process_mode = ProcessMode.PROCESS_MODE_INHERIT
	
func _on_player_shoot():
	var b = scn_bullet.instantiate()
	b.position = %Player.position
	var pa = %Player.rotation
	b.velocity = %Player.velocity + 200 * Vector2(cos(pa), sin(pa))
	add_child(b)


func _process(delta):
	ref_progress.value += 20*delta
	if ref_progress.value >= 100:
		
