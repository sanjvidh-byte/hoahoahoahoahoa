extends Node

@onready var data_manager: DataManager = %DataManager
@onready var player: Player = $"../Player"

@onready var house: Node2D = $House
@onready var forest: Node2D = $Forest
@onready var cave: Node2D = $Cave


# Spawn the player at the appropriate location
func _ready() -> void:
	if not data_manager.data_exists():
		# Default spawn location
		player.position = house.position
		return
	
	var data := data_manager.load_data(DataKeys.TEMPLATE_DATA)
	
	# This implies that a new game was started
	if data.is_empty() or not DataKeys.MAP_POSITION_KEY in data:
		# Default spawn location
		player.position = house.position
		return
	
	# Get the location value from the data
	var location = data[DataKeys.MAP_POSITION_KEY]
	
	# Place the player in the appropriate location
	match location:
		DataKeys.HOUSE_VALUE:
			player.position = house.position
		DataKeys.FOREST_VALUE:
			player.position = forest.position
		DataKeys.CAVE_VALUE:
			player.position = cave.position
		_:
			print("Invalid position found!")
			player.position = house.position
