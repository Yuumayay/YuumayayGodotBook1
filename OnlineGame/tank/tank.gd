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
@export var lerp_position : Vector2

func _enter_tree():
	player_id = int(str(name))
	set_multiplayer_authority(player_id)

func _ready():
	damaged.connect(_on_damaged)
	if player_id == multiplayer.get_unique_id(): #自分の戦車か？
		$tankname.text = $/root/main/title/entername.text
		exp_add(0)
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
		
		shoot.rpc_id(1, bullet_position, bullet_rotation, bullet_scale, bullet_speed)

	move_and_slide()
	lerp_position = position

func _process(delta):
	if player_id != multiplayer.get_unique_id():
		position = lerp(position, lerp_position, 0.1)

@rpc("any_peer") 
func shoot(bullet_position, bullet_rotation, bullet_scale, bullet_speed):
	var bullet = bullet_pr.instantiate()
	bullet.init_position = bullet_position
	bullet.rotation = bullet_rotation
	bullet.scale = bullet_scale
	bullet.speed = bullet_speed
	bullet.player_id = player_id
	bullet.name = str(randi())
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
func destroyed(exp_num):
	# 破壊された状態にする
	set_physics_process(false) #入力不可
	$hitbox/shape.disabled = true #当たり判定無効化
	$area/shape.disabled = true #当たり判定無効化
	set_multiplayer_authority(1) #所有権を戻す
	modulate.a = 0.1 #薄く表示する
	
	#経験値玉をばらまく
	for i in range(exp_num):
		var expball = expball_pr.instantiate()
		expball.position = position
		expball.lerp_position = position + Vector2(randf_range(-200, 200), randf_range(-200, 200))
		$/root/main/exps.add_child.call_deferred(expball)

func _on_damaged():
	#全員に経験値ばらまき
	var exp_num = tank_level * 20
	for id in multiplayer.get_peers(): 
		destroyed.rpc_id(id, exp_num)
	destroyed.call_deferred(exp_num)
	
	await get_tree().create_timer(2).timeout
	$/root/main/title.show()	
