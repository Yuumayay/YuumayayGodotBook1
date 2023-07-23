extends CharacterBody2D

@export var move_speed: int
@export var can_tread: bool

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = move_speed
	move_and_slide()


func _on_area_body_entered(body):
	if body.name == "Character" and can_tread:
		UI.heal(10)
		Audio.get_node("Hit").play()
		queue_free()
