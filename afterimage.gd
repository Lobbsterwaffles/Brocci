extends Bullet


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tw = create_tween()
	tw.set_ease(Tween.EASE_IN)
	tw.tween_property(self,"position",Vector2(150,0), 1)
	tw.tween_property(self,"position",Vector2(8000,0), 3)
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
