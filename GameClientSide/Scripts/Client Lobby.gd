extends Node2D

const connectIP = "34.94.217.163"
const connectPort = 44444;
	
func _ready():
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func _on_connectButton_pressed():
	print("Joining network")
	var client = NetworkedMultiplayerENet.new()
	client.create_client(connectIP, connectPort)
	get_tree().set_network_peer(client)
	
func _connected_ok():
	$connectButton.hide()
	$connectButton.disabled = true
	print("Connection Successful")
	
func _connected_fail():
	print("Connection Unsuccessful")
	
func _server_disconnected():
	print("ERROR: Server disconnected")