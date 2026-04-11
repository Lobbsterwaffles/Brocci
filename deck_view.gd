extends Control

func populate(cards):
	for c in cards:
		%grid.add_child(c.as_node())

func clear():
	for c in %grid.get_children():
		c.queue_free()
