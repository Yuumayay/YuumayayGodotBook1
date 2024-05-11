extends CharacterBody2D

class_name Tank
signal damaged

var bullet_pr = preload("res://tank/bullet.tscn")
var expball_pr = preload("res://exp/exp.tscn")

var rotation_velocity := 0.0

const SPEED = 0.1
const MOVE_SPEED = 200
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var tank_exp := 0
var tank_exp_max := 10
var tank_level := 1
var player_id := 0

func _enter_tree():
	player_id = int(str(name))
	set_multiplayer_authority(player_id)

func _ready():
	if player_id == multiplayer.get_unique_id(): #自分の戦車か？
		$tankname.text = $/root/main/title/entername.text
		damaged.connect(_on_damaged)
	else: #ほかの戦車
		$camera.enabled = false
		set_physics_process(false)
	
func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		rotation_velocity = direction * SPEED
	else:
		rotation_velocity = move_toward(rotation_velocity, 0, SPEED)
	var direction_y = Input.get_axis("ui_up", "ui_down")
	if direction_y:
		velocity = Vector2.from_angle($body.rotation) * MOVE_SPEED * direction_y * -1
	else:
		velocity = lerp(velocity, Vector2.ZERO, delta * 10)
	$body.rotation += rotation_velocity
	$cannon.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot"):
		var bullet_speed = clamp(6 + (tank_level - 1) * 0.2, 0, 12)#レベルで弾がはやくなる、最大12
		var bullet_scale = scale * 0.25 #弾は戦車と連動して大きくなる
		var bullet_position = position
		var bullet_rotation = $cannon.rotation
		var bullet_id = randi()
		for id in multiplayer.get_peers(): #自分以外の全員にshootしたと送る
			shoot.rpc_id(id, bullet_position, bullet_rotation, bullet_scale, bullet_speed, bullet_id)
		shoot(bullet_position, bullet_rotation, bullet_scale, bullet_speed, bullet_id) #自分のshootを実行

	move_and_slide()

@rpc("any_peer") # 全員発信可、遊びに来た人にも発信可
func shoot(bullet_position, bullet_rotation, bullet_scale, bullet_speed, bullet_id):
	var bullet = bullet_pr.instantiate()
	bullet.position = bullet_position
	bullet.rotation = bullet_rotation
	bullet.scale = bullet_scale
	bullet.speed = bullet_speed
	bullet.player_id = player_id
	bullet.name = str(bullet_id)
	$/root/main/bullets.add_child(bullet)

func _on_area_area_entered(area):
	var body = area.get_parent()
	if body is Exp:
		body.queue_free()
		if player_id == multiplayer.get_unique_id(): #自分の戦車
			exp_add(1)

func exp_add(v):
	tank_exp += v
	if tank_exp >= tank_exp_max:
		tank_exp -= tank_exp_max
		tank_level += 1
		#レベルで戦車が大きくなってズームアウト
		scale = Vector2(0.2,0.2) + (tank_level - 1) * Vector2(0.015,0.015) 
		$camera.zoom = Vector2(1,1) + (tank_level - 1) * Vector2(-0.01,-0.01) 
		tank_exp_max = round(10 + (tank_level - 1) * 5)
	
	var expbar = $/root/main/ui/expbar
	expbar.value = tank_exp
	expbar.max_value = tank_exp_max
	var exp_label = $/root/main/ui/exp
	var level_label = $/root/main/ui/level
	exp_label.text = "%d / %d" % [tank_exp, tank_exp_max]
	level_label.text = "Lv %02d" % tank_level
		
@rpc("any_peer")
func spawn_exp():
	set_physics_process(false) #入力不可
	$hitbox/shape.disabled = true #当たり判定無効化
	$area/shape.disabled = true #当たり判定無効化
	set_multiplayer_authority(1) #所有権を戻す
	modulate.a = 0.1
	
	for i in range(tank_level * 20):
		var expball = expball_pr.instantiate()
		expball.position = position
		expball.lerp_position = position + Vector2(randf_range(-200, 200), randf_range(-200, 200))
		$/root/main/exps.add_child.call_deferred(expball)
	
@rpc("any_peer")
func delete_bullet(del_bullet_id):
	if $/root/main/bullets.has_node(str(del_bullet_id)):
		$/root/main/bullets.get_node(str(del_bullet_id)).queue_free()

func _on_damaged(bullet_id):
	#当たった弾は全員の画面から弾消し
	for id in multiplayer.get_peers():
		delete_bullet.rpc_id(id, bullet_id)
		
	#全員に経験値ばらまき
	for id in multiplayer.get_peers(): 
		spawn_exp.rpc_id(id)
	spawn_exp.call_deferred()
	
	await get_tree().create_timer(2).timeout
	$/root/main/title.show()	
