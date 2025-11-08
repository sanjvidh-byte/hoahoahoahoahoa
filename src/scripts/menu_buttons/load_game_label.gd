extends RichTextLabel

const MAIN_SCENE = preload("uid://kpetl5ut10yo")

const UNAVAILABLE_COLOR := "#a0a0a0"

var _has_data := false
var _started_interact := false

@onready var data_manager: DataManager = %DataManager
@onready var transition_screen: TransitionScreen = $"../../../../../TransitionScreen"


# Check to see if any existing data already exists
func _ready() -> void:
	_has_data = data_manager.data_exists()
	
	if not _has_data:
		text = "[color=%s]%s[/color]" % [UNAVAILABLE_COLOR, text]


func button_press() -> void:
	if _has_data:
		print("Loading data!")
		_started_interact = true
		transition_screen.fade_in()
	else:
		print("No data!")


func _on_transition_screen_transition_ended(animation_name: StringName) -> void:
	if _started_interact and animation_name == TransitionScreen.FADE_IN_NAME:
		get_tree().change_scene_to_packed(MAIN_SCENE)
