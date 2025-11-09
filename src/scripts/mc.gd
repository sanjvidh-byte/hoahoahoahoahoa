extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var x_direction: int  = 0
var isDead: bool = false
const DELAY_TILL_RESTART: float = 1

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D



func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("left"):
		x_direction = -1
		sprite_2d.flip_h = true
	elif Input.is_action_pressed("right"):
		x_direction = 1
		sprite_2d.flip_h = false
	else:
		x_direction = 0
	
	velocity.x = x_direction * SPEED
	
	# Play animations
	if is_on_floor():
		if x_direction != 0:
			sprite_2d.play("run")
		else:
			sprite_2d.play("idle")

	move_and_slide()

func die() -> void:
	isDead = true
	
	set_deferred("velocity", Vector2.ZERO)
	sprite_2d.rotation_degrees = 90
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.is_in_group("stars"):
		die()
		
