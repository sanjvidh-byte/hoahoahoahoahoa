class_name InteractableObject
extends StaticBody2D

@export var dialogue_file: JSON
@export var interaction_area: Area2D

var dialogue_dictionary: Array[Dictionary] = []

var in_area := false
# NOTE: has_interacted will be left as true once the interaction is done
var has_interacted := false
var player_node: Player

@onready var interact_sprite_2d: Sprite2D = $InteractSprite2D


func _ready() -> void:
	# Connect to the body_entered signal if there is a valid Area2D
	if interaction_area == null or dialogue_file == null:
		return
	
	interaction_area.body_entered.connect(show_interaction_popup)
	interaction_area.body_exited.connect(hide_interaction_popup)
	
	# Read the contents of the dialogue file
	var file := FileAccess.open(dialogue_file.resource_path, FileAccess.READ)
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


func _input(event: InputEvent) -> void:
	if not in_area or has_interacted:
		return
	
	has_interacted = true
	
	if not event.is_action_pressed("interact"):
		has_interacted = false
		return
	
	interact_sprite_2d.hide()
	start_interaction()


func show_interaction_popup(body: Node2D) -> void:
	if has_interacted or not body is Player:
		return
	
	in_area = true
	interact_sprite_2d.show()
	player_node = body


func hide_interaction_popup(body: Node2D) -> void:
	if not body is Player:
		return
	
	in_area = false
	interact_sprite_2d.hide()
	player_node = null


func start_interaction() -> void:
	player_node.disable_movement()
	
	var dialogue: Dialogue = player_node.get_dialogue_node()
	dialogue.add_next_dialogue(dialogue_dictionary)
	dialogue.show_dialogue()
	
	# Wait until the dialogue is finished
	await dialogue.dialogue_done
	dialogue.hide_dialogue()
	
	player_node.enable_movement()
