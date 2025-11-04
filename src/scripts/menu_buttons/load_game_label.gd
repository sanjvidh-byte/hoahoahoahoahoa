extends RichTextLabel

const UNAVAILABLE_COLOR := "#a0a0a0"

var _has_data := false

@onready var data_manager: DataManager = %DataManager


# Check to see if any existing data already exists
func _ready() -> void:
	_has_data = data_manager.data_exists()
	
	if not _has_data:
		text = "[color=%s]%s[/color]" % [UNAVAILABLE_COLOR, text]


func button_press() -> void:
	if _has_data:
		print("Loading data!")
	else:
		print("No data!")
