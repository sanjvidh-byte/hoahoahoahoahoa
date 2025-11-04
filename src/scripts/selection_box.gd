class_name SelectionBox
extends MarginContainer

const ANIMATION_NAME := "open_selections"
const BUTTON_METHOD_NAME := "button_press"

var _enabled := false
var _has_selected := false

var _current_index := 0
var _labels: Array[RichTextLabel] = []

@onready var v_box_container: VBoxContainer = $Background/Padding/VBoxContainer
@onready var load_game_label: RichTextLabel = $Background/Padding/VBoxContainer/LoadGameLabel
@onready var animation_player: AnimationPlayer = $Background/AnimationPlayer


func _ready() -> void:
	# Put labels into an array in order
	for item in v_box_container.get_children():
		if not item is RichTextLabel:
			continue
		
		_labels.append(item)
	
	animation_player.play("setup")


func _input(event: InputEvent) -> void:
	# Only run when the function is enabled
	if not _enabled:
		return
	
	# Set the default index to 0 if it's the first input
	if not _has_selected:
		_has_selected = true
		_current_index = 0
	else:
		if event.is_action_pressed("interact"):
			var label := _labels[_current_index]
			
			# Call the button function if it exists
			# This uses duck typing to avoid making an abstract class specifically for this
			if label.has_method(BUTTON_METHOD_NAME):
				label.button_press()
			else:
				print(label.name, " has no function!")
			
			return
		
		if event.is_action_pressed("move_up"):
			# Move the focus up
			if _current_index > 0:
				_current_index -= 1
		elif event.is_action_pressed("move_down"):
			# Move the focus down
			if _current_index < len(_labels)-1:
				_current_index += 1
	
	# Grab the focus of the label
	_labels[_current_index].grab_focus()


func _on_transition_screen_transition_ended(animation_name: StringName) -> void:
	# Action to perform when the transition screen disappears
	if animation_name == TransitionScreen.FADE_OUT_NAME:
		animation_player.play(ANIMATION_NAME)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != ANIMATION_NAME:
		return
	
	_enabled = true
