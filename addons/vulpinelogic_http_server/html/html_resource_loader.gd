@tool
class_name VulpineLogicHTMLFormatLoader

extends ResourceFormatLoader

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["html", "htmltemplate"])


func _get_resource_type(path: String) -> String:
	return "Resource"


func _get_resource_script_class(path:String) -> String:
	return "VulpineLogicHTML"


func _handles_type(type: StringName) -> bool:
	return ClassDB.is_parent_class(type, "Resource")


func _load(path:String, original_path:String, use_sub_threads:bool, cache_mode:int):
	var file = FileAccess.open(path, FileAccess.READ)
  
	if file == null:
		return FileAccess.get_open_error()
  
	var resource := VulpineLogicHTML.new()
	resource.html = file.get_as_text()
	return resource
