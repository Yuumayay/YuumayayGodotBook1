extends Node2D

class_name Target

signal damaged

var expball_pr = preload("res://exp/exp.tscn")

func _ready():
	damaged.connect(_on_damaged)

func _on_damaged():
	queue_free()
	for i in range(randi_range(3,5)):
		var expball = expball_pr.instantiate()
		expball.position = position
		expball.lerp_position = position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		$/root/main/exps.add_child.call_deferred(expball)
	
