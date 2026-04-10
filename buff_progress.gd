extends TextureProgressBar

func _ready():
	$Timer.timeout.connect(queue_free)

func _process(delta):
	value = 1 - $Timer.time_left / $Timer.wait_time
