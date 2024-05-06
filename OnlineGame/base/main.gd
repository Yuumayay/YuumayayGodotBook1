extends Node

var tank_pr = preload("res://tank/tank.tscn")
var target_pr = preload("res://target/target.tscn")

func _ready():
	while true:
		var target = target_pr.instantiate()
		target.position = Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
		$targets.add_child(target)
		await get_tree().create_timer(1).timeout

func tank_spawn(entername):
	var tank = tank_pr.instantiate()
	tank.get_node("tankname").text = entername
	$players.add_child(tank)

func _on_title_start_pressed(entername):
	tank_spawn(entername)
