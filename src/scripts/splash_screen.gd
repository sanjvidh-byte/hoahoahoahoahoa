extends Control

const MAIN_MENU = preload("uid://cc03a2d54eawg")
const ANIMATION_NAME := "splash_animation"

var _started := false
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("RESET")


func _input(event: InputEvent) -> void:
	if _started:
		return
	
	if not event.is_action_pressed("interact"):
		return
	
	print("Welcome!")
	
	_started = true
	
	animation_player.play(ANIMATION_NAME)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != ANIMATION_NAME:
		return
	
	get_tree().change_scene_to_packed(MAIN_MENU)
