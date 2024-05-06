extends Node

const PORT = 1111 # 部屋のドア番号
const SERVER_IP = "127.0.0.1" #部屋の住所

var tank_pr = preload("res://tank/tank.tscn")
var target_pr = preload("res://target/target.tscn")

var my_tank 	#自分のtankノード

func _ready():
	while true:
		var target = target_pr.instantiate()
		target.position = Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
		$targets.add_child(target)
		await get_tree().create_timer(1).timeout

func wait_spawn(path): #ノードがスポーンするまで待つ関数。
	while true:
		await get_tree().create_timer(0.01).timeout
		if has_node(path):
			return get_node(path)
			
func _on_title_start_pressed(entername):
	# 部屋にあそびにいく (クライアント）
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(SERVER_IP, PORT)
	multiplayer.set_multiplayer_peer(peer)
	
	var my_player_id = multiplayer.get_unique_id() #プレイヤー番号をとる
	
	my_tank = await wait_spawn("players/" + str(my_player_id))
	my_tank.get_node("tankname").text = entername
		
func _on_title_room_pressed():
	# 部屋をつくる （サーバー）
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	multiplayer.set_multiplayer_peer(peer)
	multiplayer.peer_connected.connect(on_new_player)
	multiplayer.peer_disconnected.connect(on_exit_player)

func on_new_player(player_id):
	print("だれかあそびにきたよ プレイヤー番号:", str(player_id))
	
	var tank = tank_pr.instantiate()
	tank.name = str(player_id)
	$players.add_child(tank)
	
func on_exit_player(player_id):
	print("かえったよ プレイヤー番号: ", str(player_id) )
	$players.get_node(str(player_id)).queue_free()
