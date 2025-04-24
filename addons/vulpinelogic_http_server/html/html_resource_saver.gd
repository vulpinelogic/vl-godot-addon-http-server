@tool
class_name VulpineLogicHTMLFormatSaver

extends ResourceFormatSaver

func _get_recognized_extensions(resource:Resource) -> PackedStringArray:
	return PackedStringArray(["html", "htmltemplate"])


func _recognize(resource:Resource) -> bool:
	return resource is VulpineLogicHTML


func _save(resource:Resource, path:String, flags:int):
	if not(resource is VulpineLogicHTML):
		return ERR_INVALID_DATA

	var file = FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		return FileAccess.get_open_error()
  
	file.store_string(resource.html)
	file.close()
	return OK
