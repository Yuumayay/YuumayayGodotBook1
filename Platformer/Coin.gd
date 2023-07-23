extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func _on_area_body_entered(body):
	if body.name == "Character":
		UI.damage(10)
		UI.coin_add(1)
		Audio.get_node("Coin").play()
		queue_free()
