extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_host_pressed() -> void:
	server.connect_server();
	if server.state == WebSocketPeer.STATE_OPEN:
		get_tree().change_scene_to_file("res://aquario.tscn")
		print("Estado atual do servidor: ", server.state)
	elif server.state == WebSocketPeer.STATE_CLOSED:
		print("STATE_CLOSED")
	elif server.state == WebSocketPeer.STATE_CLOSING:
		print("STATE_CLOSING")
	elif server.state == WebSocketPeer.STATE_CONNECTING:
		print("STATE_CONNECTING")
	else:
		print("Estado atual do servidor: ", server.state)


func _on_join_pressed() -> void:
	pass # Replace with function body.
