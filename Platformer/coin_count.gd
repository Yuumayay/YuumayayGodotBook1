extends CanvasLayer

var coin = 0
@onready var label = $Label

func coin_add(value):
	coin += value
	var length = str(coin).length()
	if length == 1:
		label.text = "0" + str(coin)
	else:
		label.text = str(coin)
