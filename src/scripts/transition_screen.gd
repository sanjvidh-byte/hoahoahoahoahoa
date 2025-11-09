class_name TransitionScreen
extends ColorRect

signal transition_ended(animation_name: StringName)

const FADE_IN_NAME := "fade_in"
const FADE_OUT_NAME := "fade_out"

@export var fade_out_on_ready := true

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if fade_out_on_ready:
		visible = true
		animation_player.play("RESET")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != FADE_OUT_NAME and anim_name != FADE_IN_NAME:
		if anim_name == "RESET":
			if fade_out_on_ready:
				animation_player.play(FADE_OUT_NAME)
		
		return
	
	transition_ended.emit(anim_name)


func fade_in() -> void:
	animation_player.play("fade_in")
