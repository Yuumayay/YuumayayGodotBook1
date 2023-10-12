extends Sprite2D

@onready var healthbar: ProgressBar = $HealthBar

var max_hp: int = 50
var hp: int
var is_player: bool

const DAMAGE_MIN: float = 1.0

func init(pl):
	hp = max_hp
	is_player = pl
	

# Called when the node enters the scene tree for the first time.
func _ready():
	healthbar.max_value = max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	healthbar.value = hp


func damage_calc(atk):
	var ret = randi_range(ceil(atk * 0.8), ceil(atk * 1.2))
	if ret <= DAMAGE_MIN:
		ret = DAMAGE_MIN
	return ret

func _on_castle_hitbox_area_entered(area):
	if area.get_parent().is_player == is_player or area.name != "AttackHitBox":
		return
	var damage = damage_calc(area.get_parent().chara_attack)
	hp -= damage
	print(hp)
	if hp <= 0 and $/root/Gameplay.win_state == "fight":
		if is_player:
			$/root/Gameplay.win_state = "lose"
			$/root/Gameplay/UI/Lose.show()
		else:
			$/root/Gameplay.win_state = "win"
			$/root/Gameplay/UI/Win.show()
