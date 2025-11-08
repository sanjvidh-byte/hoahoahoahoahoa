class_name DataManager
extends Node
## A class handling data saving and loading.
##
## This class can be used by loading the object into a scene as a Node.
## When saving or loading data, the file name, the file directory,
## and the file extensions are kept constant.

## The directory that save data will be saved to.
const DATA_BASE_PATH := "user://"

## The file name that the main save file will use.
const MAIN_FILE := "data"

## The file extension that the main save file will use.
const DATA_EXT := ".svfl"

## The file name that the backup save file will use.
const BACKUP_FILE := "backup"

## The file extension that backup save files will use.
const BACKUP_EXT := ".bkfl"


## A wrapper around the internal [method _save_data] function.
## The file names for this function are handled by the class.
func save_data(data: Dictionary, make_backup: bool = false) -> void:
	_save_data(MAIN_FILE, data, BACKUP_FILE, make_backup)


## A wrapper around the internal [method _load_data] function.
## The file names for this function are handled by the class.
func load_data(reference_structure: Dictionary = {}) -> Dictionary:
	return _load_data(MAIN_FILE, reference_structure, BACKUP_FILE)


## A function to check whether any save data exists at the
## locations defined in this class.
## This includes both a main data file and a backup data file.
func data_exists() -> bool:
	var path := DATA_BASE_PATH + MAIN_FILE + DATA_EXT
	var backup_path := DATA_BASE_PATH + BACKUP_FILE + BACKUP_EXT
	
	return (FileAccess.file_exists(path) or FileAccess.file_exists(backup_path))


## A function to save data formatted as a [Dictionary] into a [JSON] file
## named [param filename]. In most cases, [method save_data] should be called.
##
## A backup of the original save data can also be created by passing in
## [param make_backup] as [code]true[/code] with a valid [param backup_name].
## Note that the file directory and file extension are handled by the class.
func _save_data(filename: String, data: Dictionary, backup_name: String = "", make_backup: bool = false) -> void:
	var path := DATA_BASE_PATH + filename + DATA_EXT
	var backup_path := DATA_BASE_PATH + backup_name + BACKUP_EXT
	
	var string_data := JSON.stringify(data)
	
	if make_backup and FileAccess.file_exists(path):
		var original_file := FileAccess.open(path, FileAccess.READ)
		var original_data := original_file.get_as_text()
		original_file.close()
		
		var backup_file := FileAccess.open(backup_path, FileAccess.WRITE)
		backup_file.store_string(original_data)
		backup_file.close()
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(string_data)
	file.close()


## A function to load data from a [JSON] file into a [Dictionary].
## In most cases, [method load_data] should be called.
##
## The [param reference_structure] argument should contain a dictionary with
## keys set to default values (e.g. [code]0.0[/code]). This allows for types to
## be fixed once the data is loaded.
##
## The [param backup_filename] may be set to try loading a backup file if
## the main file is not found.
func _load_data(filename: String, reference_structure: Dictionary = {}, backup_filename: String = "") -> Dictionary:
	var path := DATA_BASE_PATH + filename + DATA_EXT
	
	# If the file doesn't exist, try the backup file
	if not FileAccess.file_exists(path):
		var backup_path := DATA_BASE_PATH + backup_filename + BACKUP_EXT
		
		# If both files do not exist, then return an empty dictionary
		if not FileAccess.file_exists(backup_path):
			return {}
		
		# Set path as the backup path
		path = backup_path
	
	return _load_data_internal(path, reference_structure)


func _load_data_internal(path: String, reference_structure: Dictionary = {}) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	var file_string := file.get_as_text()
	file.close()
	
	var json_data: Dictionary = JSON.parse_string(file_string)
	
	if len(reference_structure) == 0:
		return json_data
	
	return _fix_types(json_data, reference_structure)


func _fix_types(loaded: Dictionary, reference: Dictionary) -> Dictionary:
	for key in loaded:
		if not key in reference:
			continue
		
		var ref_val = reference[key]
		var ref_val_type := typeof(ref_val)
		
		var loaded_val = loaded[key]
		var loaded_val_type := typeof(loaded_val)
		
		# Recurse through dictionary values
		if ref_val_type == TYPE_DICTIONARY:
			if loaded_val_type != TYPE_DICTIONARY:
				print("Not a dictionary in loaded data!")
			else:
				_fix_types(loaded_val, ref_val)
			
			continue
		
		if loaded_val_type == ref_val_type:
			continue
		
		var converted_val = type_convert(loaded_val, ref_val_type)
		
		# Since ref_val should be a default value (blank), this can be done to
		# see if it failed to convert (if so, then skip the data)
		if converted_val == ref_val:
			continue
		
		loaded[key] = converted_val
	
	return loaded
