class_name Dialogue
extends Control
## Class to manage dialogue for interactions.
##
## Generally, dialogue should be sent through [method add_next_dialogue]
## which sends multiple dialogues at once as an array of [Dictionary] objects.
##
## A speaker can be set through the [method change_speaker_texture] and
## [method change_speaker_name] functions.
## A speaker's dialogue can be set through the [method change_dialogue_text]
## function.

## Signal to notify an object that dialogue has finished
signal dialogue_done

## Base path for image files
const BASE_FILEPATH = "res://assets/img/"

## Dictionary key to set a speaker's texture in [method add_next_dialogue]
static var texture_key := "TEXTURE"
## Dictionary key to set a speaker's name in [method add_next_dialogue]
static var name_key := "NAME"
## Dictionary key to set a speaker's text in [method add_next_dialogue]
static var dialogue_key := "DIALOGUE"
# TODO: (Feature) Add a key to allow selecting an option alongside text progression

## How many characters should be shown per second
@export var characters_per_second: float = 12.5

# Array holding the next lines of dialogue
var _next_dialogue: Array[Dictionary]

# The current running tween on the dialogue object
var _current_tween: Tween

# Variable to hold whether the interaction input has been set already
var _opened_interaction := false

# Variable to hold whether the dialogue was skipped to the end
var _skipped_dialogue := false

# Variable to hold what the last checked dialogue was
var _last_checked_dialogue: int

# Variable to hold what the currently showing dialogue is
var _current_dialogue_index: int

@onready var _speaker_texture: TextureRect = $SpeakerTexture
@onready var _speaker_name_label: RichTextLabel = \
		$DialogueBox/Background/InnerMargins/VBoxContainer/SpeakerNameLabel
@onready var _dialogue_text_label: RichTextLabel = \
		$DialogueBox/Background/InnerMargins/VBoxContainer/DialogueTextLabel
@onready var _auto_play_timer: Timer = \
		$DialogueBox/Background/InnerMargins/VBoxContainer/DialogueTextLabel/AutoPlayTimer
@onready var _end_of_dialogue_animation_player: AnimationPlayer = \
		$DialogueBox/Background/InnerMargins/VBoxContainer/EndOfDialogueLabel/AnimationPlayer


func _input(event: InputEvent) -> void:
	if _current_tween == null or not _current_tween.is_running():
		if not _skipped_dialogue:
			return
	
	if not event.is_action_pressed("interact"):
		return
	
	# Debounce the initial interaction input
	if not _opened_interaction:
		_opened_interaction = true
		return
	
	# Skip the _between_dialogue_action function
	if _skipped_dialogue:
		_end_of_dialogue_animation_player.stop()
		_end_of_dialogue_animation_player.play("RESET")
		
		_skipped_dialogue = false
		_move_to_next_dialogue()
	else:
		# TODO: (Feature) Add an action for "speeding up" dialogue text
		# instead of skipping the entire dialogue
		_current_tween.kill()
		_dialogue_text_label.visible_ratio = 1.0
		
		_skipped_dialogue = true
		_between_dialogue_action()


## Set the speaker's texture using a [Texture2D]
func change_speaker_texture(new_texture: Texture2D) -> void:
	_speaker_texture.texture = new_texture


## Set the speaker's name as a [String].
## This function supports BBCode as a [RichTextLabel] is used.
func change_speaker_name(new_name: String) -> void:
	_speaker_name_label.text = new_name


## Set the speaker's dialogue as a [String].
## This function supports BBCode as a [RichTextLabel] is used.
func change_dialogue_text(new_text: String) -> void:
	_dialogue_text_label.text = new_text


## Set multiple lines of dialogue as an [Array] of multiple [Dictionary] objects.
## To set the speaker's texture, add a [Sprite2D] under [member texture_key].
## To set the speaker's name, add a [String] under [member name_key].
## To set the speaker's text, add a [String] under [member dialogue_key].
func add_next_dialogue(lines: Array[Dictionary]) -> void:
	_next_dialogue = lines


func show_dialogue() -> void:
	visible = true
	_move_to_next_dialogue()


func hide_dialogue() -> void:
	visible = false
	_dialogue_text_label.visible_ratio = 0.0


# Internal method to move to the next piece of dialogue
func _move_to_next_dialogue() -> void:
	if len(_next_dialogue) <= 0:
		dialogue_done.emit()
		return
	
	# Get the next line of dialogue
	_current_dialogue_index += 1
	var line: Dictionary = _next_dialogue.pop_front()
	
	if line == null:
		return
	
	# NOTE: null can be used to clear a texture
	if texture_key in line:
		var texture = line[texture_key]
		var new_texture
		
		if texture == null:
			new_texture = null
		else:
			# Load the image
			new_texture = load(BASE_FILEPATH + texture)
		
		_speaker_texture.texture = new_texture
	
	if name_key in line:
		_speaker_name_label.text = line[name_key]
	
	var read_time: float = 0
	
	if dialogue_key in line:
		_dialogue_text_label.text = line[dialogue_key]
		read_time = len(line[dialogue_key]) / characters_per_second
	
	_dialogue_text_label.visible_ratio = 0.0
	
	_current_tween = create_tween()
	_current_tween.tween_property(_dialogue_text_label, "visible_ratio", 1.0, read_time)
	_current_tween.tween_callback(_between_dialogue_action)


func _between_dialogue_action() -> void:
	# This allows the waiting time to be skipped
	_skipped_dialogue = true
	
	# Set what the current dialogue is
	_last_checked_dialogue = _current_dialogue_index
	
	# Start playing the "next dialogue" animation
	_end_of_dialogue_animation_player.play("indicator")
	_auto_play_timer.start()


func _on_auto_play_timer_timeout() -> void:
	# Once the timer is done, check if the dialogue has already progressed
	if _last_checked_dialogue == _current_dialogue_index:
		_end_of_dialogue_animation_player.stop()
		_end_of_dialogue_animation_player.play("RESET")
		
		_move_to_next_dialogue()
