extends RichTextLabel

const MAIN_SCENE = preload("uid://kpetl5ut10yo")

var _has_data := false

@onready var data_manager: DataManager = %DataManager
@onready var transition_screen: TransitionScreen = $"../../../../../TransitionScreen"

# Check to see if any existing data already exists
# This information is used to provide a warning before data is overwritten
func _ready() -> void:
	_has_data = data_manager.data_exists()


func button_press() -> void:
	print("Start!")
	transition_screen.fade_in()


func _on_transition_screen_transition_ended(animation_name: StringName) -> void:
	if animation_name == TransitionScreen.FADE_IN_NAME:
		get_tree().change_scene_to_packed(MAIN_SCENE)
