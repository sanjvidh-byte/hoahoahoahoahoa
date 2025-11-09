extends Control


func _ready() -> void:
	$Button.pressed.connect(try_again)# Replace with function body.


func try_again():
	get_tree().change_scene_to_file("res://scenes/minigame2.tscn")
