extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Audio.get_node("BGM").play()
