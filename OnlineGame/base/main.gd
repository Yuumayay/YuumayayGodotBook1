extends Node

var tank_pr = preload("res://tank/tank.tscn")
var target_pr = preload("res://target/target.tscn")

func _ready():
	var tank = tank_pr.instantiate()
	$players.add_child(tank)
	while true:
		var target = target_pr.instantiate()
		target.position = Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
		$targets.add_child(target)
		await get_tree().create_timer(1).timeout
