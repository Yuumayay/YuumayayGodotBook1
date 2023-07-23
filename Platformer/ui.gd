extends CanvasLayer

var coin = 0
@onready var label = $Label

var hp = 100
@onready var health = $Health

func coin_add(value):
	coin += value
	var length = str(coin).length()
	if length == 1:
		label.text = "0" + str(coin)
	else:
		label.text = str(coin)

func damage(value):
	Audio.get_node("Damage").play()
	hp -= value
	health.value = hp

func heal(value):
	Audio.get_node("Heal").play()
	hp += value
	health.value = hp
