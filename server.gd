extends Node2D

var socket := WebSocketPeer.new()

var socket_data := {}

var connected := false

var local_player: Player
var other_players := {} # Dicionário para armazenar posições de outros jogadores
var json := JSON.new()

var player_scene = preload("res://player.tscn")

func connect_server():
	# Conecta ao servidor WebSocket
	#await get_tree().create_timer(randi_range(0,5)).timeout
	var err = socket.connect_to_url("ws://localhost:8080")
	if err != OK:
		print("Erro ao conectar ao servidor WebSocket: ", err)
	else:
		print("Tentando conectar ao servidor WebSocket...")


var state : int = WebSocketPeer.STATE_CLOSED;

func _process(_delta):
	socket.poll()
	state = socket.get_ready_state() 
	if state == WebSocketPeer.STATE_OPEN:
		if not connected:
			connected = true
			print("Conexão estabelecida com o servidor WebSocket.")
		# Enviar posição do jogador
		# Receber posições dos outros jogadores
		while socket.get_available_packet_count() > 0:
			var data = socket.get_packet()
			_on_data_received(data)

		if socket_data.has("id"):
			if local_player == null:
				spawn_player(socket_data.id, true)
			socket_data.pos.x = local_player.global_position.x
			socket_data.pos.y = local_player.global_position.y
			send_position()
		
	elif state == WebSocketPeer.STATE_CLOSING:
		# Continue polling para fechar corretamente
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket fechado com código: %d, razão: %s. Limpo: %s" % [code, reason, code != -1])
		connected = false
		socket_data = {}
		if local_player != null:
			local_player.call_deferred("queue_free")

func spawn_player(id, local = false):
	var player_instance = player_scene.instantiate() as Player
	player_instance.id = id
	player_instance.name = "player_" + str(id)
	player_instance.is_local = local
	if local == true:
		player_instance.modulate = Color.RED
		player_instance.global_position.x = socket_data["pos"].x;
		player_instance.global_position.y = socket_data["pos"].y;
		player_instance.z_index = 0;
		local_player = player_instance
	add_child(player_instance)
	pass

func send_position():
	var data = {
		"type": "move",
		"body": {
			"pos": {
				"x": socket_data.pos.x,
				"y": socket_data.pos.y
			}
		}
	}
	socket.send_text(JSON.stringify(data))

func _on_data_received(_data):
	var message = _data.get_string_from_utf8()
	var parse = json.parse(message)
	if parse == OK and json.data.has("body"):
		var data = json.data
		var body = json.data.body
		# print(data.type)
		match data.type:
			"init":
				socket_data.id = body.id
				socket_data.pos = body.pos
				for client in body.playerlist:
					var player_name = "player_" + str(client.id)
					if !has_node(player_name):
						spawn_player(client.id)
					var player = get_node(player_name)
					player.global_position.x = client.pos.x
					player.global_position.y = client.pos.y
					pass
			"move":
				var player_id = body.id
				var player_name = "player_" + str(player_id)
				if !has_node(player_name):
					spawn_player(player_id)
				var player = get_node(player_name)
				player.global_position.x = body.pos.x
				player.global_position.y = body.pos.y
			"disconnected":
				var player_id = body.id
				var player_name = "player_" + str(player_id)
				if has_node(player_name):
					get_node(player_name).queue_free()
		# var position = parsed.result
		# var player_id = position.get("id", null)
		# if player_id and player_id != get_tree().get_network_unique_id():
		# 	other_players[player_id] = position
			#update_player_position(player_id, position)
	# else:
	# 	print("Erro ao analisar a posição recebida.")

#func update_player_position(player_id, position):
	## Lógica para atualizar ou criar o nó do jogador com player_id
	#var player_node = get_node_or_null("Players/" + str(player_id))
	#if not player_node:
		## Se o jogador não existe, instancia um novo
		#var player_scene = preload("res://Player.tscn") # Caminho para a cena do jogador
		#player_node = player_scene.instance()
		#player_node.name = str(player_id)
		#get_node("Players").add_child(player_node)
	#player_node.global_position = Vector2(position["x"], position["y"])
