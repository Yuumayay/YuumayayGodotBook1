extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func _on_area_body_entered(body):
	if body.name == "Character":
		Audio.get_node("Coin").play()
		queue_free()
