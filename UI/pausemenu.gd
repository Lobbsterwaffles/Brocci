extends Control


func _ready():
	%resume_btn.pressed.connect(
		func ():
			hide()
			get_tree().paused = false
	)
	%retry_btn.pressed.connect(func(): get_tree().change_scene_to_packed(preload("res://rootly.tscn")))
