extends CharacterBody2D

@export var speed = 400

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta):
	
	get_input()
	
	if Input.is_action_just_pressed("dash"):
		
		velocity = Input.get_vector("left", "right", "up", "down") * 10000
	

	move_and_slide()
