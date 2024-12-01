class_name IncendieServer extends Node
 
var socket
signal getBulbs_ok
signal setBulbPosition_ok
signal setBulbID_ok

func _init():
	
	socket = PacketPeerUDP.new()
	socket.set_broadcast_enabled(true)
	var error = socket.set_dest_address("192.168.1.255", 8888)
	if error != OK: 
		print("socket connection : ", error)
	pass
	
func getBulbs():
	var http_request = HTTPRequest.new()
	add_child(http_request)	
	http_request.request_completed.connect(func(_result, _response_code, _headers, body):
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		remove_child(http_request)
		getBulbs_ok.emit(response.bulbs)
	)
	http_request.request("http://localhost:8080/listRaw", [], HTTPClient.METHOD_GET)
	return getBulbs_ok

func setBulbPosition(MAC_ADDRESS, position):
	var http_request = HTTPRequest.new()
	add_child(http_request)	
	http_request.request_completed.connect(func(_result, _response_code, _headers, body):
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		remove_child(http_request)
		setBulbPosition_ok.emit(response.data)
	)
	var request = JSON.stringify({
		#"PWD": GameState.PWD, 
		#"USER":GameState.USER, 
		"data" : [MAC_ADDRESS, position]
	})
	http_request.request("http://localhost:8000/setPosition", [], HTTPClient.METHOD_POST, request)
	return setBulbPosition_ok

func setBulbID(MAC_ADDRESS, id):
	var http_request = HTTPRequest.new()
	add_child(http_request)	
	http_request.request_completed.connect(func(_result, _response_code, _headers, body):
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		remove_child(http_request)
		setBulbID_ok.emit(response.data)
	)
	var request = JSON.stringify({
		"PWD": GameState.PWD, 
		"USER":GameState.USER, 
		"data" : [MAC_ADDRESS, id]
	})
	http_request.request("http://localhost:8000/move", [], HTTPClient.METHOD_POST, request)
	return setBulbID_ok

func controlBulbs(values):
	print(values)
	if(values.size() == 0):
		return
	var error = socket.put_packet(PackedByteArray(values))
	if error != OK: 
		print("socket send : ", error)
	pass
