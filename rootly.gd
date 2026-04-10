extends Node2D

var scn_enemy = preload("res://enemy.tscn")
var scn_bullet = preload("res://bullet.tscn")
var scn_card = preload("res://card.tscn")
var scn_buff = preload("res://buff_progress.tscn") 

var ref_progress
var ref_cc

var cards = []

var effect_good = [
	["deal 2x damage", func (): buff_player_dmg(2, 10)],
	["go real fast", func (): buff_player_ms(1.5, 10)],
	["gain 10 max hp", func (): gain_max_hp(10)],
	["gain 10 speed", func (): gain_ms(10)],
]

var effect_bad = [
	["spawn one enemy", func (): spawn_enemy_ring(1)],
	["spawn two enemies", func (): spawn_enemy_ring(2)],
	["spawn eight enemies", func (): spawn_enemy_ring(8)],
	["spawn five enemies", func (): spawn_enemy_ring(5)],
]

var card_def = []

func _init(n_pool = 10):
	var good = []
	var bad = []
	while good.size() < n_pool:
		good.append_array(effect_good)
	while bad.size() < n_pool:
		bad.append_array(effect_bad)
	good.shuffle()
	for i in n_pool:
		card_def.append(mkcard("", good[i][0], bad[i][0], good[i][1], bad[i][1]))

func mkcard(name, top, bot, ...effects):
	var c = scn_card.instantiate()
	c.get_node("name").text = name
	c.get_node("toptext").text = top
	c.get_node("bottext").text = bot
	c.play.connect(
		func ():
			for e in effects:
				e.call()
	)
	return c

func spawn_enemy_ring(n):
	for i in range(n):
		var e = scn_enemy.instantiate()
		var angle = 2 * PI * randf()
		var radius = 200 + 20 * randf()
		e.position = %Player.position + radius * Vector2(cos(angle), sin(angle))
		add_child(e)

func draw_card(c):
	cards.append(c)
	ref_cc.add_child(c)

func draw_hand(n = 3):
	card_def.shuffle()
	for i in n:
		draw_card(card_def[i])

func _ready():
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	%Player.shoot.connect(_on_player_shoot)
	ref_progress = get_node("%ui/hud/ProgressBar")
	ref_cc = get_node("%ui/hud/card_container")

	draw_hand()
	process_mode = ProcessMode.PROCESS_MODE_INHERIT

	get_node("%ui/hud/card_hero/Timer").timeout.connect(_on_hero_timeout) 

	
func _on_player_shoot():
	var b = scn_bullet.instantiate()
	b.position = %Player.position
	var pa = %Player.rotation
	b.velocity = %Player.velocity + 200 * Vector2(cos(pa), sin(pa))
	add_child(b)

func play_cards():
	ref_progress.value = 0
	if cards.is_empty():
		draw_hand()
		return

	var c = cards.pop_front()
	c.reparent(get_node("ui/hud/card_hero"), false)
	get_node("%ui/hud/card_hero/Timer").start(1)
	c.play.emit()
	
func _on_hero_timeout():
	var hero = get_node("%ui/hud/card_hero")
	var hnc = hero.get_child_count()
	if hnc > 1:
		hero.remove_child(hero.get_child(-1))
	
func _process(delta):
	ref_progress.value += 50*delta
	if ref_progress.value >= 100:
		call_deferred("play_cards")

func buff_player_ms(c, t):
	var nbuff = scn_buff.instantiate()
	%Player.speed *= c
	get_node("%ui/hud/buff_bar").add_child(nbuff)
	nbuff.get_node("Label").text = "+MS"
	nbuff.get_node("Timer").timeout.connect(func (): %Player.speed /= c)
	nbuff.get_node("Timer").start(t)
	
func buff_player_dmg(c, t):
	var nbuff = scn_buff.instantiate()
	%Player.dmg_mult *= c
	get_node("%ui/hud/buff_bar").add_child(nbuff)
	nbuff.get_node("Label").text = "DMG"
	nbuff.get_node("Timer").timeout.connect(func (): %Player.dmg_mult /= c)
	nbuff.get_node("Timer").start(t)
	
func gain_max_hp(x):
	%Player.health_max += x
	%Player.health += x

func gain_ms(x):
	%Player.speed += x
