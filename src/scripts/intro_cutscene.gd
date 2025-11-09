extends Node2D

@export var cutscene_dialogue: JSON
@export var start_delay: int = 2

@onready var player: Player = $Player
@onready var dialogue: Dialogue = %Dialogue


# Play the introduction dialogue
func _ready() -> void:
	if not cutscene_dialogue:
		return
	
	player.disable_movement()
	
	var dialogue_dictionary: Array[Dictionary] = []
	
	# Same code from interactable_object.gd
	# Read the contents of the dialogue file
	var file := FileAccess.open(cutscene_dialogue.resource_path, FileAccess.READ)
	var string_content := file.get_as_text()
	file.close()
	
	var json_content = JSON.parse_string(string_content)
	if json_content == null:
		return
	
	for info in json_content["contents"]:
		var converted: Dictionary = {}
		
		if Dialogue.texture_key in info:
			converted[Dialogue.texture_key] = info[Dialogue.texture_key]
		
		if Dialogue.name_key in info:
			converted[Dialogue.name_key] = info[Dialogue.name_key]
			
		if Dialogue.dialogue_key in info:
			converted[Dialogue.dialogue_key] = info[Dialogue.dialogue_key]
		
		dialogue_dictionary.append(converted)
	
	dialogue.add_next_dialogue(dialogue_dictionary)
	await get_tree().create_timer(start_delay).timeout
	
	dialogue.show_dialogue()
	
	await dialogue.dialogue_done
	dialogue.hide_dialogue()
	
	player.enable_movement()
