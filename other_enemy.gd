extends Enemy

@export var base_speed = 100
@export var dash_factor = 1.5
var target = null

func _ready():
	super()
	%notice.area_entered.connect(notice_enter)

func notice_enter(area):
	var h = area as PlayerHurtbox
	if not h:
		return
	if target:
		return
	target = area.global_position
	speed = 2 * base_speed
	%notice_timer.timeout.connect(
		func():
			target = null
			speed = base_speed
	, CONNECT_ONE_SHOT
	)
	%notice_timer.start(2)
	
func _physics_process(delta):
	if target and global_position.distance_to(target) < 10:
		target = null
	
	if target:
		%marker.global_position = target
		velocity = dash_factor * speed * 60 * delta * position.direction_to(target)
	else:
		velocity = speed * 60 * delta * position.direction_to(ref_player.position)
	move_and_slide()
