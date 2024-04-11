extends CharacterBody2D

var bullet_pr = preload("res://tank/bullet.tscn")

var rotation_velocity := 0.0

const SPEED = 0.1
const MOVE_SPEED = 200
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


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
	$/root/main/bullets.add_child(bullet)
