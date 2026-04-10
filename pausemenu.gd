extends Control

@onready var resume_btn = get_node("resume_btn")

func _ready():
	resume_btn.pressed.connect(
		func ():
			hide()
			get_tree().paused = false
	)
