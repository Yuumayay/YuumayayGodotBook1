extends Node2D

var character = preload("res://src/character.tscn")
var castle = preload("res://src/castle.tscn")
var ui = preload("res://src/ui.tscn")

var castle_image: Array = [preload("res://image/castle.png"), preload("res://image/enemycastle.png")]
var castle_distance = 500

var player_castle: Sprite2D
var enemy_castle: Sprite2D

@onready var cam = $Cam

const ZOOM_DISTANCE = 450.0
const CAM_OFFSET_X = 0.0
const CAM_OFFSET_Y = -300.0
const CAM_OFFSET_ZOOM = 0.8

var money: float = 0.0
var money_speed: float = 10.0
var money_count: Label
var money_limit: float = 100.0

var chr_reload: float = 0.0

var win_state: String = "fight"

# ゲームスタートしたとき
func _ready():
	Audio.get_node("Fight1").play()
	
	# カメラズームの計算
	var zoom_value = ZOOM_DISTANCE / castle_distance
	cam.zoom = Vector2(zoom_value, zoom_value) * CAM_OFFSET_ZOOM
	
	# カメラ位置の調整
	cam.position.x = CAM_OFFSET_X
	cam.position.y = CAM_OFFSET_Y
	
	# 敵・味方の城を生成
	for i in range(2):
		# 城シーンをコピー、テクスチャ設定
		var new_castle = castle.instantiate()
		new_castle.texture = castle_image[i]
		if i == 0: # 味方側
			player_castle = new_castle
			new_castle.position.x = castle_distance
			new_castle.init(true)
		elif i == 1: # 敵側
			enemy_castle = new_castle
			new_castle.position.x = -castle_distance
			new_castle.init(false)
		# 城を子として追加
		add_child(new_castle)
	
	var new_ui = ui.instantiate()
	add_child(new_ui)
	
	var button: Button = new_ui.get_node("Button")
	button.pressed.connect(_on_button_1_pressed)
	
	money_count = new_ui.get_node("MoneyCount")
	
	# 敵召喚(	仮)
	while true:
		var new_chr = character.instantiate()
		new_chr.position = enemy_castle.position
		new_chr.is_player = false
		new_chr.init()
		
		add_child(new_chr)
		await get_tree().create_timer(3).timeout

func _process(delta):
	chr_reload -= delta
	money += delta * money_speed
	money = clamp(money, 0.0, money_limit)
	money_count.text = str(floor(money)) + " P / 100 P"

# 召喚ボタンが押されたとき
func _on_button_1_pressed():
	# 戦闘が終わっているならreturn
	if win_state != "fight":
		return
	
	# 召喚待機時間中ならreturn
	if chr_reload > 0.0:
		return
	
	# moneyが足りていたらmoneyを減らす
	if money >= 50:
		money -= 50
	# 足りなかったらreturn
	else:
		return
	
	# キャラクターシーンをコピー、初期設定
	var new_chr = character.instantiate()
	new_chr.position = player_castle.position
	new_chr.init()
	
	# 召喚待機設定
	chr_reload = new_chr.chara_reload
	
	# キャラクターを子として追加
	add_child(new_chr)
