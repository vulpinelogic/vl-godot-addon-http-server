@tool
class_name VulpineLogicHTMLImportPlugin

extends EditorImportPlugin


func _get_import_order() -> int:
	return 0


func _get_importer_name():
	return "com.vulpinelogic.import.html"


func _get_priority() -> float:
	return 1.0


func _get_visible_name():
	return "HTML"


func _get_recognized_extensions():
	return ["html", "htmltemplate"]


func _get_save_extension():
	return "html"


func _get_resource_type():
	return "Resource"


func _get_preset_count():
	return 0


func _get_preset_name(preset_index):
	return ""


func _get_import_options(path, preset_index):
	return []


func _import(source_file, save_path, options, platform_variants, gen_files):
	var file = FileAccess.open(source_file, FileAccess.READ)

	if file == null:
		return FAILED
	
	var html = VulpineLogicHTML.new()
	html.html = file.get_as_text()

	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(html, filename)
