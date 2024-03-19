class_name IncendieServer extends Node
 
var socket

func _init():
	
	socket = PacketPeerUDP.new()
	socket.set_broadcast_enabled(true)
	var error = socket.set_dest_address("192.168.1.255", 8888)
	if error != OK: 
		print("socket connection : ", error)
	pass
	
func getBulbs(x:Callable):
	var http_request = HTTPRequest.new()
	add_child(http_request)	
	http_request.request_completed.connect(func(result, response_code, headers, body):
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		x.call(response.bulbs)
		remove_child(http_request)
	)
	http_request.request("http://localhost:8080/listRaw", [], HTTPClient.METHOD_GET)

func controlBulbs(values):
	if(values.size() == 0):
		return
	var error = socket.put_packet(PackedByteArray(values))
	if error != OK: 
		print("socket send : ", error)
	pass
