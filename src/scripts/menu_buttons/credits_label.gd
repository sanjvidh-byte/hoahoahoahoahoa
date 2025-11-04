extends RichTextLabel

@onready var credits_pane: NinePatchRect = $"../../../../../CreditsPane"


func button_press() -> void:
	credits_pane.visible = not credits_pane.visible


func _on_focus_exited() -> void:
	credits_pane.visible = false
