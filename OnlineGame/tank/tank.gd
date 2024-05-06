extends CharacterBody2D

var bullet_pr = preload("res://tank/bullet.tscn")

var rotation_velocity := 0.0

const SPEED = 0.1
const MOVE_SPEED = 200
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var tank_exp := 0
var tank_exp_max := 10
@export var tank_level := 1
var tank_name := ""
var my_tank = false
var player_id = -1

func _enter_tree():
	player_id = str(name).to_int()
	$MultiplayerSynchronizer.set_multiplayer_authority(player_id)
	if player_id == multiplayer.get_unique_id():
		my_tank = true
	
func _physics_process(delta):
	if my_tank:
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
			shoot()
		
	move_and_slide()

func shoot():
	var bullet = bullet_pr.instantiate()
	bullet.rotation = $cannon.rotation
	bullet.position = position
	bullet.scale = scale * 0.25 #弾は戦車と連動して大きくなる
	bullet.speed = clamp(6 + (tank_level - 1) * 0.2, 0, 12) #レベルで弾がはやくなる、最大12
	$/root/main/bullets.add_child(bullet)

func _on_area_area_entered(area):
	var body = area.get_parent()
	if body is Exp:
		body.queue_free()
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
