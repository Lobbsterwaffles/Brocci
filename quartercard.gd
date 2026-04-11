extends PanelContainer

func tlabel(t):
	var lbl = Label.new()
	lbl.text = t
	lbl.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	return lbl

func populate_hbox(h, left, right):
	# h.add_child(mkspacer(1))
	h.add_child(left)
	# h.add_child(mkspacer(2))
	h.add_child(right)
	# h.add_child(mkspacer(1))
	
func mkspacer(ratio):
	var s = Control.new()
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_stretch_ratio = ratio
	return s

func do_swap(x, y):
	assert(x.get_child_count() < 2)
	assert(y.get_child_count() < 2)
	x.get_child(0).reparent(y, false)
	y.get_child(0).reparent(x, false)

func vswap_left():
	do_swap(%topleft, %botleft)

func vswap_right():
	do_swap(%topright, %botright)
