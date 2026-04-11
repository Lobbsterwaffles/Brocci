extends Control


func _ready():
	%resume_btn.pressed.connect(
		func ():
			hide()
			get_tree().paused = false
	)
