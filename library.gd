extends Node


enum CardColor { RED, GREEN, YELLOW }

enum CardCategory { GAIN, BUFF, SPAWN, LONG, SHORT }

var color_image = [
	preload("res://Sprites/heart.png"),
	preload("res://Sprites/cabbage.png"),
	preload("res://Sprites/lihgtning.png"),
]

enum Weapon { BONE, POISON, AFTERIMAGE, HEARTSLASH, ZAP, SOURPATCH, CUKE, MAX_WEAPON }


var weapon_sprite = [
	# ...

]


class Card:
	# hack idk how to share from outer scope 
	var color_image = [
		preload("res://Sprites/heart.png"),
		preload("res://Sprites/cabbage.png"),
		preload("res://Sprites/lihgtning.png"),
	]

	var category_label = ["gain","buff","spawn","long","short"]
	var scn_qc = preload("res://quartercard.tscn")

	var top_cat
	var top_color
	var bot_cat
	var bot_color
	func _init(a, b, c, d):
		top_cat = a
		top_color = b
		bot_cat = c
		bot_color = d

	func mksprite(tex):
		var s = TextureRect.new()
		s.texture = tex
		return s

	func mscc(ch):
		var c = CenterContainer.new()
		c.custom_minimum_size = Vector2(45, 45)
		c.add_child(ch)
		return c

	func mkcard(a,b,c,d):
		var c1 = scn_qc.instantiate()
		c1.get_node("%topleft").add_child((a))
		c1.get_node("%topright").add_child((b))
		c1.get_node("%botleft").add_child((c))
		c1.get_node("%botright").add_child((d))
		return c1

	func tlabel(t):
		var lbl = Label.new()
		lbl.text = t
		lbl.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		return lbl

	func as_node():
		return mkcard(
			mscc(tlabel(category_label[top_cat])),
			(mksprite(color_image[top_color])),
			mscc(tlabel(category_label[bot_cat])),
			(mksprite(color_image[bot_color])),
		)

	func swap_top(other):
		var cat = top_cat
		var color = top_color
		top_cat = other.top_cat
		top_color = other.top_color
		other.top_cat = cat
		other.top_color = color

var STARTING_DECK = [
	Card.new(CardCategory.BUFF, CardColor.RED, CardCategory.SPAWN, CardColor.RED),
	Card.new(CardCategory.BUFF, CardColor.RED, CardCategory.SPAWN, CardColor.RED),

	Card.new(CardCategory.BUFF, CardColor.YELLOW, CardCategory.SPAWN, CardColor.YELLOW),
	Card.new(CardCategory.BUFF, CardColor.YELLOW, CardCategory.SPAWN, CardColor.YELLOW),

	Card.new(CardCategory.BUFF, CardColor.GREEN, CardCategory.SPAWN, CardColor.GREEN),
	Card.new(CardCategory.BUFF, CardColor.GREEN, CardCategory.SPAWN, CardColor.GREEN),
]

func random_card():
	return Card.new(
		CardCategory.values().pick_random(),
		CardColor.values().pick_random(),
		CardCategory.values().pick_random(),		
		CardColor.values().pick_random(),
	)
		
