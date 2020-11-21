extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_connectButton_pressed():
	print("Joining network")
	var client = NetworkedMultiplayerENet.new()
	print("Connecting to IP: ", $IP.get_line(0), " Port: ", $Port.get_line(0))
	client.create_client("192.168.86.24", 4242)
	#client.create_client($IP.get_line(0), int($Port.get_line(0)))
	get_tree().set_network_peer(client)
	$connectButton.hide()
	$connectButton.disabled = true
	print("Connection Successful")