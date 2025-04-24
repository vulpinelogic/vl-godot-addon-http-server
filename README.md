# vulpinelogic_http_server

GDScript-native basic HTTP server

This repository only contains the add-on. A demo will be made available in [vl-godot-addon-demos](https://github.com/vulpinelogic/vl-godot-addon-demos) sometime soon.

The HTTP server addon is primarily intended to support the HTTP server needs of other VulpineLogic addons. It has, however, been designed to operate independently. Improvement PRs are welcome in the case that the community finds this addon useful. Just keep in mind that this addon is not intended to become as complex or capable as general purpose web servers such as Nginx and Apache.

## Features

- Basic HTTP server

## Installation

### Dependencies

This addon depends on [vulpinelogic_uri](https://github.com/vulpinelogic/vl-godot-addon-uri). Follow the installation instructions in that repo before proceding.

### Using the Asset Library

This addon may be submitted to the Asset Library once it reaches a 1.0.0 release. There is no estimated release date.

### Manual installation

Manual installation lets you use pre-release versions of this add-on by
following its `main` branch.

- Clone this Git repository:

```bash
git clone https://github.com/vulpinelogic/vl-godot-addon-http-server.git
```

Alternatively, you can
[download a ZIP
archive](https://github.com/vulpinelogic/vl-godot-addon-http-server/archive/master.zip)
if you do not have Git installed.

- Move the `addons/` folder to your project folder.
- In the editor, open **Project > Project Settings**, go to **Plugins**
  and enable the **vulpinelogic_http_server** plugin.

## Usage

**This addon has only been tested with Godot 4.x**

- Add a `VulpineLogicHTTPServer` node to your scene tree.
- Place an `index.html` file somewhere under `res://`, such as `res://public/index.html`

```gdscript
var server: VulpineLogicHTTPServer = $HTTPServer
var index_page: VulpineLogicHTML = preload("res://public/index.html")

func _ready() -> void:
	server.add_route("GET", "/", _on_index_route)
	await server.listen()
	print("HTTP server listening on port %s" % server.port)


func _on_index_route(_request: VulpineLogicHTTPServer.Request) -> Dictionary:
	return { "content": index_page.html }
```

Visit `http://localhost:3000/` to view the index page.

## Route Handlers

Route handlers receive a request object that provides:

- `headers`, a Dictionary of header names and values
- `method`, the HTTP verb/method of the request
- `path`, the path portion of the request URI
- `uri`, the entire request URI
- `version`, the HTTP protocol version requested
- `body`, the body of the request

The Dictionary returned from the handler can include the following keys:

- `content`, a String or PackedByteArray to send to the client
- `headers`, a Dictionary of header names and their values
- `status`, an int or String containing the response status, such as 200, 404, or 500
- `status_message`, a message to include on the status line of the response

## Things to Watch Out For

As of version 0.1.0, the server runs in the main thread. The 1.0.0 release is expected to remedy this, but there is no estimated completion date for that release.

## License

Copyright © 2025 VulpineLogic and contributors

Unless otherwise specified, files in this repository are licensed under the
MIT license. See [LICENSE.md](LICENSE.md) for more information.
