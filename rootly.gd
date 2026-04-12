extends Node2D

var scn_enemy = preload("res://enemy.tscn")
var scn_other_enemy = preload("res://other_enemy.tscn")
var scn_lemon_enemy = preload("res://lemon_enemy.tscn")
var scn_bullet = preload("res://bullet.tscn")
var scn_poison = preload("res://poison.tscn")
var scn_card = preload("res://card.tscn")
var scn_buff = preload("res://buff_progress.tscn") 
var scn_bone = preload("res://bone.tscn")
var scn_xporb = preload("res://xporb.tscn")

var ref_progress
var ref_cc
var ref_lbl_deck
var ref_lbl_ms
var ref_lbl_dmg
var HAND_CARDS = 4


func spawn_xporb(pos, scn, on_pickup):
	var xporb = scn_xporb.instantiate()
	xporb.position = pos
	xporb.pickup.connect(on_pickup)
	call_deferred("add_child", xporb)

func spawn_enemy_ring(n, scn, xporb_effect):
	for i in range(n):
		var e = scn.instantiate()
		var angle = 2 * PI * randf()
		var radius = 200 + 20 * randf()
		e.position = %Player.position + radius * Vector2(cos(angle), sin(angle))
		e.die.connect(func(pos): spawn_xporb(pos, scn, xporb_effect))
		add_child(e)

class PoisonTrail:
	var i = 0
	var n = 10
	var pts = []
	var last = null
	var scnp = preload("res://poison.tscn")

	func emit(pos):
		var b = scnp.instantiate()
		b.position = pos

		if last != null  and last.distance_to(pos) < 30:
			return null

		var r
		if i < n:
			r = b
			pts.append(b)
		else:
			r = null
			pts[i % n].position = pos

		last = pos
		i += 1
		return r

var ptrail  
		
var my_deck = []
var my_hand = []
var my_discard = []

func draw1():
	if my_deck.is_empty():
		my_deck = my_discard
		my_discard = []

	var c = my_deck.pop_front()
	my_hand.append(c)
	ref_cc.add_child(c.as_node())

func _ready():
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	# %Player.shoot.connect(_on_player_shoot)
	%bone_timer.timeout.connect(shoot_bone)

	%Player.get_node("pickup").area_entered.connect(
		func(oa):
			oa.pickup.emit()
			oa.queue_free()
	)
	ref_progress = get_node("%ui/hud/ProgressBar")
	ref_cc = get_node("%ui/hud/card_container")
	ref_lbl_deck = get_node("ui/hud/%lbl_deck")
	ref_lbl_ms = get_node("ui/hud/%lbl_ms")
	ref_lbl_dmg = get_node("ui/hud/%lbl_dmg")

	process_mode = ProcessMode.PROCESS_MODE_INHERIT

	$hero_timer.timeout.connect(_on_hero_timeout) 

	ptrail = PoisonTrail.new()
	
	$poison_timer.timeout.connect(
		func():
			var pel = ptrail.emit(%Player.position)
			if pel:
				add_child(pel)
	)
	$poison_timer.start(0.56)

	get_node("%ui/hud/pause_btn").pressed.connect(
		func():
			get_tree().paused = true
			get_node("%ui/pausemenu").show()
	)
	get_node("%ui/hud/deck_btn").pressed.connect(show_deckview)
	get_node("%ui/deck_view/close_btn").pressed.connect(quit_deckview)
	get_node("%ui/hud/drafting_btn").pressed.connect(begin_drafting)
	get_node("%ui/drafting").card_chosen.connect(on_card_chosen)
		
	my_deck.append_array(Library.STARTING_DECK) 
	for i in HAND_CARDS:
		draw1()

	# begin_drafting()

func on_card_chosen(c):
	finish_drafting()
	my_deck.append(c)

func player_poison():
	print("Poisonge")
	var b = scn_poison.instantiate()
	b.position = %Player.position
	b.velocity = Vector2.ZERO
	add_child(b)
	
func shoot_bone():
	var b = scn_bone.instantiate()
	b.position = %Player.position
	# var pa = %Player.rotation
	var pa = TAU * randf()
	var prv = 200 * Vector2(cos(pa), sin(pa))
	# b.velocity = %Player.velocity + prv
	b.velocity = prv
	add_child(b)

func play_cards():
	ref_progress.value = 0
	if my_hand.is_empty():
		for i in HAND_CARDS:
			draw1()
		return

	var c = my_hand.pop_front()
	var n = ref_cc.get_child(0)
	n.reparent(get_node("ui/hud/card_hero"), false)
	$hero_timer.start(1)
	do_card_effects(c)
	my_discard.append(c)
	
func _on_hero_timeout():
	var hero = get_node("%ui/hud/card_hero")
	if hero.get_child_count() > 0:
		hero.get_child(0).queue_free()
	
func _process(delta):
	ref_lbl_deck.text = "%d / %d" % [my_deck.size(), my_discard.size()]
	ref_lbl_ms.text = "%d" % [%Player.speed]
	ref_lbl_dmg.text = "%d%%" % [(100 * %Player.dmg_mult) as int]

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

func heal(x):
	%Player.health = min(%Player.health_max, x + %Player.health)

func gain_ms(x):
	%Player.speed += x

func begin_drafting():
	get_tree().paused = true
	get_node("%ui/drafting").show()
	get_node("%ui/drafting").process_mode = ProcessMode.PROCESS_MODE_WHEN_PAUSED
	
func finish_drafting():
	get_node("%ui/drafting").hide()
	get_node("%ui/drafting").process_mode = ProcessMode.PROCESS_MODE_DISABLED
	get_tree().paused = false

func show_deckview():
	get_tree().paused = true
	get_node("%ui/deck_view").show()
	get_node("%ui/deck_view").process_mode = ProcessMode.PROCESS_MODE_WHEN_PAUSED
	var all_cards = my_deck + my_hand + my_discard
	get_node("%ui/deck_view").populate(all_cards)

func quit_deckview():
	get_node("%ui/deck_view").hide()
	get_node("%ui/deck_view").clear()
	get_node("%ui/deck_view").process_mode = ProcessMode.PROCESS_MODE_DISABLED
	get_tree().paused = false
	
func do_card_effects(card):
	do_effect_row(card.top_cat, card.top_color)
	do_effect_row(card.bot_cat, card.bot_color)

func do_effect_row(cat, color):
	match [cat, color]:
		[Library.CardCategory.GAIN, Library.CardColor.RED]: gain_max_hp(10)
		[Library.CardCategory.GAIN, Library.CardColor.GREEN]: gain_max_hp(10)
		[Library.CardCategory.GAIN, Library.CardColor.YELLOW]: gain_ms(10)

		[Library.CardCategory.BUFF, Library.CardColor.RED]: heal(10)
		[Library.CardCategory.BUFF, Library.CardColor.GREEN]: buff_player_dmg(1.05, 5)
		[Library.CardCategory.BUFF, Library.CardColor.YELLOW]: buff_player_ms(1.15, 5)

		[Library.CardCategory.SPAWN, Library.CardColor.RED]: spawn_enemy_ring(2, scn_other_enemy, func(): %Player.gain_hearts(1))
		[Library.CardCategory.SPAWN, Library.CardColor.GREEN]: spawn_enemy_ring(2, scn_enemy, func(): %Player.gain_cabbage(1))
		[Library.CardCategory.SPAWN, Library.CardColor.YELLOW]: spawn_enemy_ring(2, scn_lemon_enemy, func(): %Player.gain_lightning(1))

		_:
			print("?? CARD")
