extends Node

@export var spawn_location: Node2D

@onready var data_manager: DataManager = %DataManager
@onready var player: Player = $"../Player"


# Spawn the player at the appropriate location
func _ready() -> void:
	if not spawn_location:
		return
	
	player.position = spawn_location.position
