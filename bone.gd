extends "res://poison.gd"

var bounces_left = 3
var max_time = 4

func _ready():
	var tw = create_tween()
	rotation = TAU * randf()
	tw.tween_property(self, "rotation", rotation + TAU - 0.1, max_time)
	tw.finished.connect(queue_free)
	$AnimatedSprite2D.play()

func on_hit():
	if 0 == bounces_left:
		queue_free()
	velocity = velocity.rotated(PI + 0.3 * PI * (randf() - 0.5))
	bounces_left -= 1
	
			
	
