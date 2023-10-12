extends AnimatedSprite2D

####### 変数宣言 #######

### 準備できたら ###
@onready var attack_start: CollisionShape2D = $AttackStart/Shape
@onready var attack_hitbox: CollisionShape2D = $AttackHitBox/Shape
@onready var chara_hitbox: CollisionShape2D = $CharacterHitBox/Shape

### プロパティ ###
@export var is_player: bool
@export var chara_speed: float
@export var chara_attack: float
@export var chara_defence: float
@export var chara_cost: int
@export var chara_reload: float
@export var chara_attack_time: float
@export var chara_attack_rate: float
@export var chara_attack_frame: float
@export var chara_attack_speed: float = 1.0
@export var chara_idle_speed: float = 1.0
@export var chara_max_hp: float
@export var chara_knockback_count: int = 3

### 変数 ###
var hp: float
var state: String
var cooldown_timer: float
var knockback_left: int
var knockback_x_speed: float = 5.0
var knockback_y_speed: float = -6.0

####### 定数宣言 #######
const DAMAGE_MIN: float = 1.0

# 毎フレーム実行
func _process(delta):
	# 戦闘が終わったら負けた側のキャラクターを消す
	if $/root/Gameplay.win_state == "win" and !is_player:
		queue_free()
	elif $/root/Gameplay.win_state == "lose" and is_player:
		queue_free()
	
	# 移動状態のとき
	if state == "idle":
		# 横に移動する
		position.x += delta * chara_speed
	
	# 攻撃状態のとき
	elif state == "attack":
		# 現在フレームが攻撃判定発生フレームより大きいなら
		if frame >= chara_attack_frame:
			# 攻撃待機状態にして攻撃当たり判定を有効化
			cooldown_timer = chara_attack_rate
			state = "cooldown"
			attack_hitbox_activate()
	
	# 攻撃待機状態のとき
	elif state == "cooldown":
		# 攻撃待機タイマーを減らす
		cooldown_timer -= delta
		# 攻撃待機タイマーが0以下なら（待機終了）
		if cooldown_timer <= 0.0:
			# 攻撃開始当たり判定を有効化して移動状態にする
			attack_start.disabled = false
			state = "idle"
			play("idle")

# 攻撃当たり判定を有効化
func attack_hitbox_activate():
	# 攻撃当たり判定をchara_attack_time秒間有効化する
	attack_hitbox.disabled = false
	await get_tree().create_timer(chara_attack_time).timeout
	attack_hitbox.disabled = true

# キャラクターの初期化
func init():
	# 準備できるまで待つ
	await ready
	
	# ステータス・アニメーション・当たり判定の初期化
	attack_hitbox.disabled = true
	hp = chara_max_hp
	state = "idle"
	knockback_left = chara_knockback_count
	sprite_frames.set_animation_loop("attack", false)
	play("idle")
	
	# 味方だったら
	if is_player:
		# 移動方向とスプライトを横反転
		chara_speed = -chara_speed
		flip_h = true
	
	# 敵だったら
	else:
		# ノックバックの方向を横反転
		knockback_x_speed = -knockback_x_speed
		flip_h = false

# 攻撃処理
func attack():
	# 攻撃開始判定を無効化
	# 接触判定と同時に実行されるため、set_deferredを使用して当たり判定を無効化する
	attack_start.set_deferred("disabled", true)
	
	# 状態を攻撃にしてアニメーション再生
	state = "attack"
	play("attack", chara_attack_speed)

# ダメージ処理
func damage(dmg):
	# hpをdmg分減らす
	hp -= dmg
	
	# ダメージ状態ではなく、hpが「ノックバックするhpのタイミング」より下なら
	if state != "damage" and hp <= chara_max_hp / float(chara_knockback_count) * (knockback_left - 1):
		
		# 状態をダメージにする
		state = "damage"
		
		# 当たり判定の無効化
		# 接触判定と同時に実行されるため、set_deferredを使用して当たり判定を無効化する
		attack_hitbox.set_deferred("disabled", true)
		attack_start.set_deferred("disabled", true)
		chara_hitbox.set_deferred("disabled", true)
		
		# 残りノックバック数を減らす（ノックバック条件を2個以上超える大ダメージを受けたときは1以上減る）
		for i in range(knockback_left, 1):
			if hp <= chara_max_hp / float(chara_knockback_count) * (i - 1):
				knockback_left -= 1
		
		# アニメーション再生
		play("damage")
		
		# ノックバックの移動
		var speed_x = knockback_x_speed
		var speed_y = knockback_y_speed
		for i in range(48):
			position.x += speed_x
			position.y += speed_y
			speed_y += 0.25
			await get_tree().create_timer(0).timeout
		
		# hpが0なら消す、それ以外なら状態を「移動」に戻す
		if hp <= 0.0:
			queue_free()
		else:
			state = "idle"
			play("idle")
		
		# 当たり判定を有効化
		attack_start.disabled = false
		chara_hitbox.disabled = false

# ダメージを計算して返す
func damage_calc(atk, def):
	var ret = randi_range(ceil(atk * 0.8), ceil(atk * 1.2)) - def
	if ret <= DAMAGE_MIN:
		ret = DAMAGE_MIN
	return ret

# 攻撃開始当たり判定に何か入った
func _on_attack_start_area_entered(area):
	# 入ったものが敵でキャラクターまたはお城の当たり判定だったら攻撃する
	if area.get_parent().is_player == is_player or area.name != "CharacterHitBox" and area.name != "CastleHitbox":
		return
	attack()

# 攻撃当たり判定に何か入った
func _on_attack_hit_box_area_entered(area):
	pass

# キャラクターの当たり判定に何か入った
func _on_character_hit_box_area_entered(area):
	# 入ったものが敵の攻撃当たり判定だったらダメージを受ける
	if area.get_parent().is_player == is_player or area.name != "AttackHitBox":
		return
	var dmg = damage_calc(area.get_parent().chara_attack, chara_defence)
	damage(dmg)
	Audio.get_node("Hit").play()
