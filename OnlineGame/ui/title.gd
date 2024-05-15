extends CanvasLayer

signal start_pressed
signal room_pressed

func _on_start_pressed():
	start_pressed.emit($entername.text)
	hide()

func _on_room_pressed():
	room_pressed.emit()
	hide()
