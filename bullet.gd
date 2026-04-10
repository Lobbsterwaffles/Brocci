class_name Bullet
extends Area2D

@export var damage = 35
@export var piercing = false
var velocity = Vector2.RIGHT

func _physics_process(delta):
	position += velocity * delta




	
