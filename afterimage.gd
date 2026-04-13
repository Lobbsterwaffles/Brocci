extends Bullet

var dir  

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tw = create_tween()
	tw.set_ease(Tween.EASE_IN)
	tw.tween_property(self,"position",position + Vector2(dir*150,0), 1)
	tw.tween_property(self,"position",position + Vector2(dir*8000,0), 3)
	scale.x = dir
	
func on_hit():
	pass	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
