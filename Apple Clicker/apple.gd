extends Sprite2D

var apple: int = 0
var apple_per_sec: int = 0
var apple_per_click: int = 1
@onready var label: Label = get_parent().get_node("appletext")

func _ready():
	while true:
		await get_tree().create_timer(1).timeout
		apple += apple_per_sec

func _process(delta):
	label.text = str(apple) + " apples"

func _input(event):
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			apple += apple_per_click
			print(apple)

func _on_button_pressed():
	if apple >= 10:
		apple -= 10
		apple_per_sec += 1


func _on_button_2_pressed():
	if apple >= 100:
		apple -= 100
		apple_per_click += 1
