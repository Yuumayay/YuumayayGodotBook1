extends CharacterBody2D

var bullet_pr = preload("res://tank/bullet.tscn")

var rotation_velocity := 0.0

const SPEED = 0.1
const MOVE_SPEED = 200
const JUMP_VELOCITY = -400.0
const BULLET_SPEED = 6
const BULLET_SPEED_ADD = 0.2
const BULLET_SPEED_MAX = 12
const BULLET_SCALE_MUL = 0.25
const TANK_SCALE = Vector2(0.2,0.2)
const TANK_SCALE_ADD = Vector2(0.015,0.015)
const CAMERA_ZOOM = Vector2(1,1)
const CAMERA_ZOOM_ADD = Vector2(-0.01,-0.01)


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var tank_exp := 0
var tank_exp_max := 10
var tank_level := 1


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
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	var bullet = bullet_pr.instantiate()
	bullet.rotation = $cannon.rotation
	bullet.position = position
	bullet.scale = scale * BULLET_SCALE_MUL
	bullet.speed = clamp(BULLET_SPEED + (tank_level - 1) * BULLET_SPEED_ADD, 0, BULLET_SPEED_MAX)
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
		scale = (tank_level - 1) * TANK_SCALE_ADD + TANK_SCALE
		$camera.zoom = (tank_level - 1) * CAMERA_ZOOM_ADD + CAMERA_ZOOM
		tank_exp_max = round(10 + (tank_level - 1) * 5)
	var expbar = $/root/main/ui/expbar
	expbar.value = tank_exp
	expbar.max_value = tank_exp_max
	var exp_label = $/root/main/ui/exp
	var level_label = $/root/main/ui/level
	exp_label.text = "%d / %d" % [tank_exp, tank_exp_max]
	level_label.text = "Lv %02d" % tank_level
