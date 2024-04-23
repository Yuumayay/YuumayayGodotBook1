extends Node2D

var expball_pr = preload("res://exp/exp.tscn")

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
		for i in range(randi_range(3,5)):
			var expball = expball_pr.instantiate()
			expball.position = body.position
			expball.lerp_position = body.position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			$/root/main/exps.add_child.call_deferred(expball)
