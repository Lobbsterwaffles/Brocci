extends Control


var cards = []
var card_nodes = [] 
var selected_card_index = null

signal card_chosen(card)

func incc(e):
	var cc = CenterContainer.new()
	cc.add_child(e)
	return cc

func testrow(card):
	var h = HBoxContainer.new()
	var lbtn = Button.new()
	lbtn.text = "L"
	var rbtn = Button.new()
	rbtn.text = "R"
	h.add_child(incc(lbtn))
	h.add_child(incc(card))
	h.add_child(incc(rbtn))
	
	lbtn.pressed.connect(
		func():
			do_vswap($shift_timer, card, "%topleft", "%botleft", "%topright", "%botright")
	)
	rbtn.pressed.connect(
		func():
			do_vswap($shift_timer, card, "%botright", "%topright", "%topleft", "%botleft")
	)
	
	return h

func mkspacer(ratio):
	var s = Control.new()
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_stretch_ratio = ratio
	return s

func _ready():
	cards = [
		Library.random_card(),
		Library.random_card(),
		Library.random_card(),
	]
	card_nodes = []
	for c in cards:
		card_nodes.append(c.as_node())

	%grid.add_child(mkspacer(1))
	%grid.add_child(testrow(card_nodes[0]))
	%grid.add_child(mkspacer(2))
	%grid.add_child(testrow(card_nodes[1]))
	%grid.add_child(mkspacer(2))
	%grid.add_child(testrow(card_nodes[2]))
	%grid.add_child(mkspacer(1))

	$shift_btn.pressed.connect(do_shift)
	$confirm_btn.pressed.connect(on_confirm)

	for i in card_nodes.size():
		card_nodes[i].get_node("btn").pressed.connect(on_click_card.bind(i))


func on_click_card(i):
	print("O C C ", i)
	for e in card_nodes:
		e.get_node("highlight").hide()
	card_nodes[i].get_node("highlight").show()
	if i == selected_card_index:
		card_chosen.emit(cards[i])
	selected_card_index = i

func on_confirm():
	if selected_card_index:
		card_chosen.emit(cards[selected_card_index])

func tween_cubic(n, start, end, defl):
	var v = end - start
	var pre = start - 0.25 * v + defl
	var post = end + 0.25 * v + defl
	return func(t):
		n.global_position = start.cubic_interpolate(end, pre, post, t)

func do_vswap(timer, card, top, bot, o1, o2):
	if not timer.is_stopped():
		return

	var tc = card.get_node(top).get_child(0)
	var bc = card.get_node(bot).get_child(0)
	# hack: reparent other squares too so layout doesn't shift
	var c1 = card.get_node(o1).get_child(0)
	var c2 = card.get_node(o2).get_child(0)

	var tpos = tc.global_position
	var bpos = bc.global_position
	tc.reparent(self)
	bc.reparent(self)
	c1.reparent(self)
	c2.reparent(self)

	var lanim = 0.5
	var tw = create_tween()
	var defl = 200
	var t2b = tween_cubic(tc, tpos, bpos, Vector2(-defl, 0))
	var b2t = tween_cubic(bc, bpos, tpos, Vector2(defl, 0))
	tw.tween_method(t2b, 0.0, 1.0, lanim)
	tw.parallel().tween_method(b2t, 0.0, 1.0, lanim)

	timer.timeout.connect(
		func():		
			tc.reparent(card.get_node(bot))
			bc.reparent(card.get_node(top))
			c1.reparent(card.get_node(o1))
			c2.reparent(card.get_node(o2))
	, CONNECT_ONE_SHOT
	)
	timer.start(lanim)

func do_shift():
	if not $shift_timer.is_stopped():
		return

	var cid = [0, 1, 2]
	var sq = ["%topleft", "%topright"]
	var paths = []
	for c in cid:
		for s in sq:
			paths.append([c,s])
			
	var pos = []
	var nodes = []
	var parent = []
	for p in paths:
		var q = card_nodes[p[0]].get_node(p[1])
		var n = q.get_child(0)
		nodes.append(n)
		parent.append(q)
		pos.append(n.global_position)
		n.reparent(self)

	var lanim = 0.75
	
	for i in paths.size() - 2:
		var ptw = create_tween()
		ptw.tween_property(nodes[i], "global_position", pos[2+i], lanim)

	var tw = create_tween()
	tw.tween_method(tween_cubic(nodes[-2], pos[-2], pos[0], Vector2(0, -200)), 0.0, 1.0, lanim)
	tw.parallel().tween_method(tween_cubic(nodes[-1], pos[-1], pos[1], Vector2(0, -200)), 0.0, 1.0, lanim)

	$shift_timer.timeout.connect(
		func():
			for i in paths.size() - 2:
				nodes[i].reparent(parent[2+i])
			nodes[-1].reparent(parent[1])
			nodes[-2].reparent(parent[0])

	, CONNECT_ONE_SHOT
	)

	$shift_timer.start(lanim)
