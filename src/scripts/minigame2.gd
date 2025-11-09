extends Node2D

@export var win_time: float = 19.0 

var time_left: float = win_time
var lastPoint = 0

@onready var star = preload("res://scenes/star.tscn")
@onready var spawn_points = $SpawnPoints.get_children()


func _ready() -> void:
	$SpawnTimer.wait_time = .3
	$SpawnTimer.start()
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout) # Replace with function body.


func _on_spawn_timer_timeout():
	var point = randi() % 10
	var star = star.instantiate()
	while(point == lastPoint):
		point = randi() % 10
	star.position = spawn_points[point].global_position
	add_child(star) 
	lastPoint = point


func _process(delta: float) -> void:
	if time_left > 0:
		time_left -= delta
		if time_left < 0:
			time_left = 0
	$TimerLabel.text = "Star shower ends in.. " + str(round(time_left * 10) / 10.0)


func _on_timer_timeout() -> void:
	$SpawnTimer.stop()
	get_tree().change_scene_to_file("res://scenes/win_scene.tscn")
