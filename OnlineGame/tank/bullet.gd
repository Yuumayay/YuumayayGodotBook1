extends Node2D

var speed := 6.0
var lifetime := 3.0
var player_id := 0

func _physics_process(delta):
	position += Vector2.from_angle(rotation) * speed
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_hitbox_area_entered(area):
	var body = area.get_parent()
	if body is Target:
		body.damaged.emit()
		queue_free()
	
	if body is Tank:
		if body.player_id == multiplayer.get_unique_id(): #自分の戦車か？
			if body.player_id != player_id: #自分が撃った弾ではないとき
				body.damaged.emit(int(str(name)))
				queue_free()
				
