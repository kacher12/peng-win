extends CharacterBody2D

@export var speed = 400
@export var dash_speed = 1200
@export var dash_steering = 5.0 

# Parametry czasu dasha
@export var min_dash_duration = 0.2
@export var max_dash_duration = 0.35

var is_dashing = false
var dash_timer = 0.0

func get_input(delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if is_dashing:
		if input_direction != Vector2.ZERO:
			var target_velocity = input_direction * dash_speed
			velocity = velocity.lerp(target_velocity, dash_steering * delta)
		return 
		
	velocity = input_direction * speed

func _physics_process(delta):
	get_input(delta)
	
	# Logika startu dasha
	if Input.is_action_just_pressed("dash") and not is_dashing:
		start_dash()
	
	# Logika trwania i kończenia dasha
	if is_dashing:
		dash_timer += delta # Zwiększamy licznik o czas, który upłynął
		

		#Maks dash
		if dash_timer >= max_dash_duration:
			stop_dash()
		# 2. Minął minimalny czas (0.2s) i gracz puścił przycisk
		elif dash_timer >= min_dash_duration and not Input.is_action_pressed("dash"):
			stop_dash()
	
	move_and_slide()

func start_dash():
	var dash_direction = Input.get_vector("left", "right", "up", "down")
	if dash_direction == Vector2.ZERO:
		return
		
	is_dashing = true
	dash_timer = 0.0 # Resetujemy licznik przy każdym starcie
	velocity = dash_direction * dash_speed

func stop_dash():
	is_dashing = false
