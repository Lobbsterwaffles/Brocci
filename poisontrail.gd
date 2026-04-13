class_name PoisonTrail
extends RefCounted

var i = 0
var n = 10
var pts = []
var last = null
var scnp = preload("res://poison.tscn")

func emit(pos):
	if last != null  and last.distance_to(pos) < 30:
		return null

	var b = scnp.instantiate()
	b.position = pos

	var r
	if i < n:
		r = b
		pts.append(b)
	else:
		r = null
		pts[i % n].position = pos

	last = pos
	i += 1
	return r
