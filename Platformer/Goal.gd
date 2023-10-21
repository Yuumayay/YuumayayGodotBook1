extends Sprite2D

var is_goal : bool = false
var coin = preload("res://coin.tscn")

func _on_area_body_entered(body):
	if body.name == "Character" and is_goal == false:
		self.frame = 1
		is_goal = true
		
		for i in range(200):
			var new_coin = coin.instantiate()
			new_coin.falldown = true
			new_coin.position.x = randf_range(-100, 100)
			new_coin.position.y = -500
			await get_tree().create_timer(0.01).timeout
			self.add_child(new_coin)
		

		# 3秒待ってからゴール！
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://stage1.tscn")
		# 次のステージにいくなら、これをつかってみよう
		# get_tree().change_scene_to_file("res://stage2.tscn")
