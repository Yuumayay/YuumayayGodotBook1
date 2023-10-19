extends Sprite2D

var apple: int = 0
var upgrade_apple_tree: int = 0
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
		upgrade_apple_tree += 1
		apple_per_sec += 5
		
		var buy_button: Button = get_parent().get_node("Button")
		buy_button.text = "リンゴの木 × "+ str(upgrade_apple_tree) +"\n(10 apples)"


func _on_button_2_pressed():
	if apple >= 100:
		apple -= 100
		apple_per_click += 1

		var buy_button: Button = get_parent().get_node("Button2")
		buy_button.text = "クリックパワー × "+ str(apple_per_click) +"\n(100 apples)"
