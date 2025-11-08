class_name Player
extends CharacterBody2D

@export var SPEED: float = 80.0
var can_move := true

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue: Dialogue = %Dialogue


func _physics_process(_delta: float) -> void:
	if not can_move:
		return
	
	# Get the horizontal direction
	var horizontal := Input.get_axis("move_left", "move_right")
	
	# Get the vertical direction
	var vertical := Input.get_axis("move_up", "move_down")
	
	# Set the vertical velocity
	if vertical:
		velocity.y = vertical * SPEED
		
		if vertical < 0:
			animated_sprite_2d.play("up")
		else:
			animated_sprite_2d.play("down")
	else:
		velocity.y = 0
	
	# Set the horizontal velocity
	if horizontal:
		velocity.x = horizontal * SPEED
		
		if horizontal < 0:
			animated_sprite_2d.play("left")
		else:
			animated_sprite_2d.play("right")
	else:
		velocity.x = 0
	
	# Diagonal movement should be normalized
	if velocity.x != 0 and velocity.y != 0:
		velocity = velocity.normalized() * SPEED
	
	# Move the player
	move_and_slide()


func disable_movement() -> void:
	can_move = false


func enable_movement() -> void:
	can_move = true


func get_dialogue_node() -> Dialogue:
	return dialogue
