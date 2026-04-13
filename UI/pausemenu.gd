extends Control


func _ready():
	%resume_btn.pressed.connect(
		func ():
			hide()
			get_tree().paused = false
	)
	%retry_btn.pressed.connect(newgame)


func newgame():
	get_node("/root/Rootly").queue_free()
	var game_scene = load("res://rootly.tscn").instantiate()
	get_tree().change_scene_to_node(game_scene)
	# add_child(game_scene)
