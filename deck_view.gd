extends Control

func _ready():
	for i in 10:
		%grid.add_child(Library.random_card().as_node())
