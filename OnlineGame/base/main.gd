extends Node

const PORT = 1111 # 部屋のドア番号
const SERVER_IP = "127.0.0.1" #部屋の住所

var tank_pr = preload("res://tank/tank.tscn")
var target_pr = preload("res://target/target.tscn")

func _ready():
	while true:
		var target = target_pr.instantiate()
		target.position = Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
		$targets.add_child(target)
		await get_tree().create_timer(1).timeout
	
@rpc("any_peer")
func tank_spawn():
	var tank = tank_pr.instantiate()
	var player_id = multiplayer.get_remote_sender_id() #送ってきた人番号
	tank.name = str(player_id)
	$players.add_child(tank)
	
func _on_title_start_pressed(entername):
	# 部屋にあそびにいく (クライアント）
	if multiplayer.get_peers().size() == 0:
		var peer = ENetMultiplayerPeer.new()
		peer.create_client(SERVER_IP, PORT)
		multiplayer.multiplayer_peer = peer
		
		await multiplayer.connected_to_server #接続完了まで待つ
	else:
		destroy.rpc_id(1, multiplayer.get_unique_id())
		await get_tree().create_timer(0.5).timeout
		
	tank_spawn.rpc_id(1) # 部屋をつくった人に、戦車スポーンをお願いする
	
func _on_title_room_pressed():
	# 部屋をつくる （サーバー）
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(on_new_player)
	multiplayer.peer_disconnected.connect(on_exit_player)

func on_new_player(player_id):
	print("だれかあそびにきたよ プレイヤー番号:", str(player_id))
	
func on_exit_player(player_id):
	print("かえったよ プレイヤー番号: ", str(player_id) )
	$players.get_node(str(player_id)).queue_free()

@rpc("any_peer")
func destroy(player_id):
	$players.get_node(str(player_id)).queue_free()
