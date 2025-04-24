@icon("res://addons/vulpinelogic_http_server/icon.png")
class_name VulpineLogicHTTPServer

extends Node

signal listening
signal startup_failed(error: Error)
signal stopped

@export var port: int = 3000

const statuses: Dictionary = {
	"200": "OK",
	"303": "See Other",
	"401": "Unauthorized",
	"403": "Forbidden",
	"404": "Not Found",
	"422": "Unprocessable Entity",
	"500": "INTERNAL SERVER ERROR"
}

var routes: Dictionary = {}

var _peers: Array[StreamPeerTCP] = []
var _peer_data: Dictionary = {}
var _server: TCPServer


func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED


func _process(_delta: float) -> void:
	if !_server or !_server.is_listening():
		return
	
	while _server.is_connection_available():
		var peer = _server.take_connection()
		
		if not _peers.has(peer):
			_peers.push_back(peer)
	
	for peer in _peers:
		var peer_data = _peer_data.get_or_add(peer, {
			"ready": false,
			"connected_at": Time.get_ticks_msec(),
			"body": "",
		})
		
		var peer_poll_error = peer.poll()
		
		if Time.get_ticks_msec() - peer_data.connected_at > 3000:
			_drop_peer(peer)
			continue
		
		if peer_poll_error != OK:
			printerr("Peer polling failure (%d)" % [ peer_poll_error ])
			continue
		
		var peer_status = peer.get_status()
		
		if not peer_data.ready:
			if peer_status != peer.Status.STATUS_NONE:
				peer_data.ready = true
		
		if peer_status == peer.STATUS_ERROR:
			_drop_peer(peer)
			continue
		
		if peer_data.ready and peer_status == peer.STATUS_NONE:
			_drop_peer(peer)
			continue
		
		if peer_status != peer.STATUS_CONNECTED:
			continue
		
		var pending_bytes = peer.get_available_bytes()
		peer_data.body += peer.get_string(pending_bytes)
		
		var request = Request.new(peer_data.body)
		
		if not request.is_complete:
			continue
			
		var route = routes.get(
			"%s::%s" % [ request.method, request.path.rstrip("/") ],
			routes.get(
				"%s::%s" % [ "*", request.path ],
				null))
		
		if route == null:
			_send_404(peer)
		else:
			var handler_result = route.call(request)
			_send_response(peer, handler_result)
			
		_drop_peer(peer)


func _exit_tree() -> void:
	_stop()


func add_route(method: String, path: String, handler: Callable) -> void:
	routes["%s::%s" % [method.to_upper(), path.rstrip("/")]] = handler


func listen() -> void:
	_stop()
	_server = TCPServer.new()
	
	var error =  _server.listen(port)
	
	if error != OK:
		startup_failed.emit(error)
	else:
		process_mode = ProcessMode.PROCESS_MODE_INHERIT
		print("HTTPServer listening on port %s" % port)
		listening.emit()


func _drop_peer(peer: StreamPeerTCP) -> void:
	peer.disconnect_from_host()
	_peers.erase(peer)
	_peer_data.erase(peer)


func _send_response(peer: StreamPeerTCP, response: Dictionary) -> void:
	var status = "%s" % [ response.get("status", "200") ]
	var status_message = response.get("status_message", _status_message_for(status))
	var content = response.get("content", "")
	var content_buffer = content.to_ascii_buffer() if content is String else content

	if (!peer.is_queued_for_deletion()):
		peer.put_data(("HTTP/1.1 %s %s\r\n" % [status, status_message]).to_ascii_buffer())
		peer.put_data(("Content-Length: %d\r\n" % [ content_buffer.size() ]).to_ascii_buffer())
		peer.put_data("Content-Type: text/html; charset=UTF-8\r\n".to_ascii_buffer())
		peer.put_data("Cache-Control: no-store\r\n".to_ascii_buffer())
		peer.put_data("Connection: close\r\n".to_ascii_buffer())
		
		if "headers" in response:
			for header in response.headers:
				peer.put_data(("%s: %s\r\n" % [ header, response.headers[header] ]).to_ascii_buffer())
			
		peer.put_data("\r\n".to_ascii_buffer())
		peer.put_data(content_buffer)


func _send_404(peer: StreamPeerTCP) -> void:
	_send_response(peer, {
		"content": "Not Found",
		"status": 404
	})


func _send_500(peer: StreamPeerTCP) -> void:
	_send_response(peer, {
		"content": "Internal Server Error",
		"status": 500
	})


func _status_message_for(status: String) -> String:
	return VulpineLogicHTTPServer.statuses.get(status, "")


func _stop() -> void:
	if _server:
		_server.stop()
	
	_server = null
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	stopped.emit()


class Request:
	extends RefCounted
	
	var headers: Dictionary = {}
	var body: Variant = ""
	var method: String = "GET":
		set(value):
			method = value.to_upper()
	
	var path: String = "/"
	var query: Dictionary = {}
	var uri: VulpineLogicURI
	var version: String = "HTTP/1.1"
	
	var is_complete: bool = false
	
	
	func _init(raw_request: String):
		_parse_request(raw_request)
	
	
	func _parse_request(raw_request: String, port: String = "", default_host: String = "localhost") -> void:
		var lines = Array(raw_request.split("\r\n"))
		var verb_resource_version = lines[0].split(" ")
		var headers_end_at = lines.find("") - 1
		
		headers = lines\
			.slice(1, headers_end_at if headers_end_at > -1 else lines.size())\
			.reduce(func (acc, entry):
				var pair = entry.split(":", true, 1)
				acc[pair[0].rstrip(" ").to_lower()] = pair[1].lstrip(" ")
				return acc
				, {})
		
		var end_of_headers = raw_request.find("\r\n\r\n")
		
		if end_of_headers > -1:
			var content_length = int(headers.get("content-length", 0))
			body = raw_request.substr(end_of_headers + 4)
			is_complete = body.length() >= content_length
			
			if is_complete and headers.get("content-type", "") == "application/json":
				body = JSON.parse_string(body)
						
		var resource = verb_resource_version[1] if lines.size() >= 2 else ''
		version = verb_resource_version[2] if lines.size() >= 3 else ''
		method = verb_resource_version[0]
		
		var full_resource = []
		full_resource.push_back("http://")
		full_resource.push_back(headers.get("host", default_host))
				
		if port.length() > 0:
			full_resource.push_back(":%s" % [ port ])
			
		full_resource.push_back(resource)

		uri = VulpineLogicURI.new("".join(full_resource))
		path = uri.path
		query = uri.query
