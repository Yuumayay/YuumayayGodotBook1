extends Node2D

class_name Exp

var lerp_position := Vector2.ZERO

func _process(delta):
	position = lerp(position, lerp_position, delta * 5)
