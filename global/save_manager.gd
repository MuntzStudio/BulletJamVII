## SaveManager - Autoload Singleton
extends Node

const SAVE_FILE := "user://save.json"
const WEB_STORAGE_KEY := "save_data"

var data: Dictionary = {}

func _ready() -> void:
	load_game()

#region SAVE
func save_game() -> void:
	var json_string := JSON.stringify(data, "\t")
	if OS.has_feature("web"):
		JavaScriptBridge.eval("""
			localStorage.setItem('%s', '%s');
		""" % [WEB_STORAGE_KEY, json_string.replace("'", "\\'")])
	else:
		var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
		if file:
			file.store_string(json_string)
			file.close()
#endregion SAVE

#region LOAD
func load_game() -> void:
	if OS.has_feature("web"):
		var result = JavaScriptBridge.eval("""
			localStorage.getItem('%s');
		""" % WEB_STORAGE_KEY)
		if result != null:
			var parsed : Variant = JSON.parse_string(str(result))
			if parsed is Dictionary:
				data = parsed
	else:
		if not FileAccess.file_exists(SAVE_FILE):
			return
		var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var parsed : Variant = JSON.parse_string(file.get_as_text())
			file.close()
			if parsed is Dictionary:
				data = parsed
#endregion LOAD

#region DELETE
func delete_save() -> void:
	data = {}
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.removeItem('%s');" % WEB_STORAGE_KEY)
	else:
		if FileAccess.file_exists(SAVE_FILE):
			DirAccess.remove_absolute(SAVE_FILE)
#endregion DELETE

#region HELPERS
func set_value(key: String, value) -> void:
	data[key] = value
	save_game()

func get_value(key: String, default = null):
	return data.get(key, default)

func has_save() -> bool:
	if OS.has_feature("web"):
		var result = JavaScriptBridge.eval("localStorage.getItem('%s');" % WEB_STORAGE_KEY)
		return result != null
	return FileAccess.file_exists(SAVE_FILE)
#endregion HELPERS
