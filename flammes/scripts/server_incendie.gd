@tool
extends Node

signal newFlamme(unique_id, macAddress, position)

# The URL we will connect to.
@export var websocket_url = "ws://localhost:8080"
@export var conected : bool = false

var socket = WebSocketPeer.new()

func disconnectServer():
	socket.close()
	conected = false
	return true

func connectServer():
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
		conected = false
		return false
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(2).timeout
	set_process(true) # Stop processing.
	conected = true
	return true

func send(data):
	if conected :
		socket.send(data)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float):
	
	socket.poll()
	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()

	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var msg = socket.get_packet().get_string_from_utf8()
			#print("Got data from server: ", msg)
			if(msg == "connection established"):
				pass
			else:
				var json = JSON.new()
				var error = json.parse(msg)
				if error == OK:
					var macAddress = json.data.MacAddress.data
					var position = json.data.position
					var unique_id = json.data.unique_id
					if typeof(unique_id) == TYPE_FLOAT and typeof(macAddress) == TYPE_ARRAY and typeof(position) == TYPE_ARRAY:
						newFlamme.emit(int(unique_id), macAddress, position)
						pass
					else:
						print("Unexpected data")
				else:
					print("JSON Parse Error: ", json.get_error_message(), " in ", msg, " at line ", json.get_error_line())

	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		conected = false
		set_process(false) # Stop processing.

func setBulbPosition(MAC_ADDRESS, position):
	if conected :
		var http_request = HTTPRequest.new()
		add_child(http_request)	
		http_request.request_completed.connect(func(_result, _response_code, _headers, body):
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			remove_child(http_request)
		)
		var request = JSON.stringify({
			"MacAddress" : MAC_ADDRESS,
			"position" : position
		})
		var headers = ["Content-Type: application/json"]
		http_request.request("http://localhost:8000/setPosition", headers, HTTPClient.METHOD_POST, request)
