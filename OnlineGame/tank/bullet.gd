extends Node2D

var speed := 6.0
var lifetime := 3.0

func _physics_process(delta):
	position += Vector2.from_angle(rotation) * speed
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_hitbox_area_entered(area):
	var body = area.get_parent()
	if body is Target:
		body.queue_free()
		queue_free()
