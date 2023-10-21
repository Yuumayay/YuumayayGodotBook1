extends Sprite2D

var falldown : bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed_y : float = 0.0

func _process(delta):
	# falldownがtrueなら、コインを落下させる
	if falldown == true:
		speed_y += gravity * delta
		position.y += speed_y * delta

func _on_area_body_entered(body):
	if body.name == "Character":
		UI.coin_add(1)
		Audio.get_node("Coin").play()
		queue_free()
