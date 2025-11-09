extends Player
# Based on the original mc.gd script
# Modified to fit with the player.gd script

const JUMP_VELOCITY = -400.0

var is_dead := false


func _init() -> void:
	SPEED = 300.0


func _physics_process(delta: float) -> void:
	if is_dead:
		velocity += get_gravity() * delta
		move_and_slide()
		return
	
	# Get the horizontal direction
	var horizontal := Input.get_axis("move_left", "move_right")
	
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


func hit() -> void:
	is_dead = true
	
	set_deferred("velocity", Vector2.ZERO)
	animated_sprite_2d.rotation_degrees = 90
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("stars"):
		hit()
