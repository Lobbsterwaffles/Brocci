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
var scn_sourpatch = preload("res://sourpatch.tscn")
var scn_afterimage = preload("res://afterimage.tscn")
var scn_cuke = preload("res://cuke.tscn")

var ref_progress
var ref_cc
var ref_lbl_deck
var ref_lbl_ms
var ref_lbl_dmg
var ref_lbl_xp
var ref_bar_xp
var HAND_CARDS = 4

var xp_total = 0
var player_level = 1

func xp_for_level(x):
	return 5 * x * x - 5 * x

var enemy_hp_bonus = 0
var enemy_dmg_mult = 1
var enemy_ms_mult = 1

func spawn_xporb(pos, scn, on_pickup):
	var xporb = scn_xporb.instantiate()
	xporb.position = pos
	xporb.pickup.connect(on_pickup)
	call_deferred("add_child", xporb)

var enemy_bullet_tint = Color(1, 0.6, 0.6, 1)

func spawn_enemy_ring(n, scn, xporb_effect):
	for i in range(n):
		var e = scn.instantiate()
		var angle = 2 * PI * randf()
		var radius = 400 + 20 * randf()
		e.position = %Player.position + radius * Vector2(cos(angle), sin(angle))
		e.die.connect(func(pos): spawn_xporb(pos, scn, xporb_effect))

		var eloadout = Loadout.new()
		var etrail = PoisonTrail.new()
		for t in eloadout.timer:
			e.add_child(t)
		eloadout.timer[Library.Weapon.POISON].timeout.connect(
			func():
				enemy_shoot_poison(e, etrail)
		)
		eloadout.timer[Library.Weapon.BONE].timeout.connect(enemy_shoot_bone.bind(e))
		## 
		add_child(e)
		# eloadout.levelup_weapon(Library.Weapon.POISON)
		eloadout.levelup_weapon(Library.Weapon.BONE)
		
func enemy_shoot_poison(e, etrail):
	var pel = etrail.emit(e.global_position)
	if pel:
		pel.shot_by_enemy = true
		pel.modulate = enemy_bullet_tint
		add_child(pel)
		pel.area_entered.connect(
			func(oa):
				if oa is not PlayerHurtbox:
					return
				%Player.take_damage(pel.damage)
				pel.on_hit()
		)
		e.tree_exiting.connect(pel.queue_free)

func enemy_shoot_bone(e):
	var b = scn_bone.instantiate()
	b.shot_by_enemy = true
	b.position = e.global_position
	b.modulate = enemy_bullet_tint
	var pa = TAU * randf()
	var prv = 200 * Vector2(cos(pa), sin(pa))
	b.velocity = prv
	e.tree_exiting.connect(b.queue_free)
	add_child(b)


var ptrail  
		
var my_deck = []
var my_hand = []
var my_discard = []

var rat_hearts = 0
var rat_cabbage = 0
var rat_lightning = 0

@onready var ref_rat_heart = get_node("/root/Rootly/ui/hud/%lbl_rat_heart")
@onready var ref_rat_cabbage = get_node("/root/Rootly/ui/hud/%lbl_rat_cabbage")
@onready var ref_rat_lightning = get_node("/root/Rootly/ui/hud/%lbl_rat_lightning")

class Loadout extends RefCounted:
	var timer = []
	var level = []
	func _init():
		for i in Library.Weapon.MAX_WEAPON:
			timer.append(Timer.new())
			level.append(0)

	func levelup_weapon(w):
		if level[w] > 0:
			level[w] += 1
		else:
			level[w] = 1
			timer[w].start(1)

var the_loadout = Loadout.new()

func shoot_poison():
	var pel = ptrail.emit(%Player.position)
	if pel:
		add_child(pel)

func draw1():
	if my_deck.is_empty():
		my_deck = my_discard
		my_discard = []

	var c = my_deck.pop_front()
	my_hand.append(c)
	ref_cc.add_child(c.as_node())

func _ready():
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	%Player.get_node("pickup").area_entered.connect(
		func(oa):
			xp_total += 1
			var next_xp = xp_for_level(1 + player_level)
			if xp_total >= xp_for_level(1 + player_level):
				player_level += 1
				call_deferred("begin_drafting")
			oa.pickup.emit()
			oa.queue_free()
	)
	ref_progress = get_node("%ui/hud/%card_progress")
	print("Refprog ", ref_progress)

	ref_cc = get_node("%ui/hud/card_container")
	ref_lbl_deck = get_node("ui/hud/%lbl_deck")
	ref_lbl_ms = get_node("ui/hud/%lbl_ms")
	ref_lbl_dmg = get_node("ui/hud/%lbl_dmg")
	ref_lbl_xp = get_node("ui/hud/%xp_lbl")
	ref_bar_xp = get_node("ui/hud/%bar_xp")

	process_mode = ProcessMode.PROCESS_MODE_INHERIT

	ptrail = PoisonTrail.new()
	the_loadout.timer[Library.Weapon.BONE].timeout.connect(shoot_bone)
	the_loadout.timer[Library.Weapon.POISON].timeout.connect(shoot_poison)
	the_loadout.timer[Library.Weapon.AFTERIMAGE].timeout.connect(shoot_afterimage)
	the_loadout.timer[Library.Weapon.SOURPATCH].timeout.connect(shoot_sourpatch)
	#the_loadout.timer[Library.Weapon.HEARTSLASH].timeout.connect(shoot_heartslash)

	for t in the_loadout.timer:
		add_child(t)

	the_loadout.levelup_weapon(Library.Weapon.BONE)

	$hero_timer.timeout.connect(_on_hero_timeout) 

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
	ref_progress.global_position = ref_cc.get_child(0).global_position

	# begin_drafting()

func on_card_chosen(c):
	finish_drafting()
	my_deck.append(c)

func shoot_bone():
	var b = scn_bone.instantiate()
	b.position = %Player.position
	# var pa = %Player.rotation
	var pa = TAU * randf()
	var prv = 200 * Vector2(cos(pa), sin(pa))
	# b.velocity = %Player.velocity + prv
	b.velocity = prv
	add_child(b)

func shoot_afterimage():
	var i = scn_afterimage.instantiate()
	i.position = %Player.position
	if %Player.velocity.x < 0:
		i.dir = -1
	else:
		i.dir = 1	
	print(i.dir)
	add_child(i)
	
func shoot_sourpatch():
	var sou = scn_sourpatch.instantiate()
	add_child(sou)

func play_cards():
	ref_progress.value = 0
	if my_hand.is_empty():
		for i in HAND_CARDS:
			draw1()
		ref_progress.hide()
		return

	ref_progress.show()


	var c = my_hand.pop_front()
	var n = ref_cc.get_child(0)
	ref_progress.global_position = n.global_position
	n.reparent(get_node("ui/hud/card_hero"), false)
	$hero_timer.start(1)
	do_card_effects(c)
	my_discard.append(c)
	
func _on_hero_timeout():
	var hero = get_node("%ui/hud/card_hero")
	if hero.get_child_count() > 0:
		hero.get_child(0).queue_free()
	
func _process(delta):
	var total_cards = my_deck.size() + my_hand.size() + my_discard.size()
	ref_lbl_deck.text = "%d / %d" % [my_deck.size(), total_cards]
	ref_lbl_ms.text = "%d" % [%Player.speed]
	ref_lbl_dmg.text = "%d%%" % [(100 * %Player.dmg_mult) as int]
	
	var xpbase = xp_for_level(player_level)
	var xpnext = xp_for_level(1 + player_level)
	var xpfrac = (xp_total - xpbase) / ((xpnext - xpbase) as float)
	ref_lbl_xp.text = "%d%% to level %d" % [(100 * xpfrac) as int, 1+player_level]
	ref_bar_xp.value = xpfrac

	ref_rat_heart.text = "%d" % [rat_hearts]
	ref_rat_cabbage.text =  "%d" % [rat_cabbage]
	ref_rat_lightning.text = "%d" % [rat_lightning]

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

func rat_gain_hearts(x):
	rat_hearts += x
	enemy_hp_bonus += 10*x
func rat_gain_cabbage(x):
	rat_cabbage += x
	enemy_dmg_mult += 0.05 * x
func rat_gain_lightning(x):
	rat_lightning += x
	enemy_ms_mult += 0.05 * x


func begin_drafting():
	get_tree().paused = true
	get_node("%ui/drafting").new_cards()
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
	player_effect_row(card.top_cat, card.top_color)
	enemy_effect_row(card.bot_cat, card.bot_color)

func player_effect_row(cat, color):
	match [cat, color]:
		[Library.CardCategory.GAIN, Library.CardColor.RED]: gain_max_hp(10)
		[Library.CardCategory.GAIN, Library.CardColor.GREEN]: gain_max_hp(10)
		[Library.CardCategory.GAIN, Library.CardColor.YELLOW]: gain_ms(10)

		[Library.CardCategory.BUFF, Library.CardColor.RED]: heal(10)
		[Library.CardCategory.BUFF, Library.CardColor.GREEN]: buff_player_dmg(1.05, 5)
		[Library.CardCategory.BUFF, Library.CardColor.YELLOW]: buff_player_ms(1.15, 5)
		
		#[Library.CardCategory.SHORT, Library.CardColor.RED]: the_loadout.levelup_weapon(Library.Weapon.HEARTSLASH)
		[Library.CardCategory.SHORT, Library.CardColor.GREEN]: the_loadout.levelup_weapon(Library.Weapon.POISON)
		[Library.CardCategory.SHORT, Library.CardColor.YELLOW]: the_loadout.levelup_weapon(Library.Weapon.SOURPATCH)

		[Library.CardCategory.LONG, Library.CardColor.RED]: the_loadout.levelup_weapon(Library.Weapon.AFTERIMAGE)
		#[Library.CardCategory.LONG, Library.CardColor.GREEN]: the_loadout.levelup_weapon(Library.Weapon.CUKE)
		[Library.CardCategory.LONG, Library.CardColor.YELLOW]: the_loadout.levelup_weapon(Library.Weapon.BONE)

		_:
			print("?? CARD")


func enemy_effect_row(cat, color):
	match [cat, color]:
		[Library.CardCategory.GAIN, Library.CardColor.RED]: rat_gain_hearts(1)
		[Library.CardCategory.GAIN, Library.CardColor.GREEN]: rat_gain_cabbage(1)
		[Library.CardCategory.GAIN, Library.CardColor.YELLOW]: rat_gain_lightning(1)

		[Library.CardCategory.SPAWN, Library.CardColor.RED]: spawn_enemy_ring(2, scn_other_enemy, func(): %Player.gain_hearts(1))
		[Library.CardCategory.SPAWN, Library.CardColor.GREEN]: spawn_enemy_ring(2, scn_enemy, func(): %Player.gain_cabbage(1))
		[Library.CardCategory.SPAWN, Library.CardColor.YELLOW]: spawn_enemy_ring(2, scn_lemon_enemy, func(): %Player.gain_lightning(1))

		_:
			print("?? CARD")
