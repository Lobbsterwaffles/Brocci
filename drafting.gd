extends Control

@onready var scn_qc = load("res://quartercard.tscn")

var cards = [] 

func tlabel(t):
	var lbl = Label.new()
	lbl.text = t
	lbl.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	return lbl

func incc(e):
	var cc = CenterContainer.new()
	cc.add_child(e)
	return cc

func testcard(a = "A", b = "B", c = "C", d = "D"):
	var c1 = scn_qc.instantiate()
	c1.get_node("%topleft").add_child(tlabel(a))
	c1.get_node("%topright").add_child(tlabel(b))
	c1.get_node("%botleft").add_child(tlabel(c))
	c1.get_node("%botright").add_child(tlabel(d))
	return c1

func testrow(card):
	var h = HBoxContainer.new()
	var lbtn = Button.new()
	lbtn.text = "L"
	var rbtn = Button.new()
	rbtn.text = "R"
	h.add_child(incc(lbtn))
	h.add_child(incc(card))
	h.add_child(incc(rbtn))
	lbtn.pressed.connect(card.vswap_left)
	rbtn.pressed.connect(card.vswap_right)
	# card.name = "card"
	# card.owner = h
	# card.unique_name_in_owner = true
	return h

func mkspacer(ratio):
	var s = Control.new()
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_stretch_ratio = ratio
	return s

func _ready():
	cards = [
		testcard("A1", "B1", "C1", "D1"),
		testcard("A2", "B2", "C2", "D2"),
		testcard("A3", "B3", "C3", "D3")
	]

	%grid.add_child(mkspacer(1))
	%grid.add_child(testrow(cards[0]))
	%grid.add_child(mkspacer(2))
	%grid.add_child(testrow(cards[1]))
	%grid.add_child(mkspacer(2))
	%grid.add_child(testrow(cards[2]))
	%grid.add_child(mkspacer(1))

	$shift_btn.pressed.connect(do_shift)

func twreparent(old, new):
	var node = old.get_child(0)
	var oldpos = old.get_child(0).global_position - self.position
	var newpos = new.get_child(0).global_position - self.position
	
	node.reparent(self)
	var tw = create_tween()
	tw.tween_property(node, "position", newpos, 1)
	tw.finished.connect(func(): node.reparent(new))

func tween_cubic(n, start, end, defl):
	var v = end - start
	var pre = start - 0.25 * v + defl
	var post = end + 0.25 * v + defl
	return func(t):
		n.global_position = start.cubic_interpolate(end, pre, post, t)

func do_shift():
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
		var q = cards[p[0]].get_node(p[1])
		var n = q.get_child(0)
		nodes.append(n)
		parent.append(q)
		pos.append(n.global_position)
		n.reparent(self)

	var lanim = 1.0
	
	for i in paths.size() - 1:
		var tw = create_tween()
		tw.tween_property(nodes[i], "global_position", pos[1+i], lanim)

	var tw = create_tween()
	tw.tween_method(tween_cubic(nodes[-1], pos[-1], pos[0], Vector2(0, -200)), 0.0, 1.0, lanim)

	$shift_timer.timeout.connect(
		func():
			for i in paths.size() - 1:
				nodes[i].reparent(parent[1+i])
			nodes[-1].reparent(parent[0])
	, CONNECT_ONE_SHOT
	)

	$shift_timer.start(lanim)

func show_cards(cards):
	for c in %grid.get_children():
		%grid.remove_child(c)
	for c in cards:
		%grid.add_child(c.duplicate())

		
