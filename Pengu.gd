extends CharacterBody2D

@export var speed = 400
@export var dash_speed = 1200
@export var dash_steering = 5.0 

# Referencja do mapy (PRZYPISZ W INSPEKTORZE!!!!!!!111)
@export var tile_map_layer: TileMapLayer

# Parametry czasu dasha
@export var min_dash_duration = 0.2
@export var max_dash_duration = 0.35

var is_dashing = false
var dash_timer = 0.0

# Zmienna do przechowywania domyślnej prędkości, aby móc do niej wracać
@onready var base_speed = speed 

func get_input(delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if is_dashing:
		if input_direction != Vector2.ZERO:
			var target_velocity = input_direction * dash_speed
			velocity = velocity.lerp(target_velocity, dash_steering * delta)
		return 
		
	velocity = input_direction * speed

func _physics_process(delta):
	# 1. Sprawdzamy podłoże ZANIM pobierzemy input, 
	# aby efekt kafelka wpłynął na aktualną klatkę
	check_current_tile()
	
	get_input(delta)
	
	# Logika startu dasha
	if Input.is_action_just_pressed("dash") and not is_dashing:
		start_dash()
	
	# Logika trwania i kończenia dasha
	if is_dashing:
		dash_timer += delta # Zwiększamy licznik do czas, który upłynął
		
		# Maks dash
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

# --- FUNKCJA DO SPRAWDZANIA KAFELKÓW ---
func check_current_tile():
	if not tile_map_layer:
		return # Zabezpieczenie, jeśli zapomnisz przypisać mapę w Inspektorze
		
	# Zamieniamy pozycję gracza (globalną) na pozycję lokalną TileMapy, 
	# a potem na współrzędne siatki (komórki)
	var local_pos = tile_map_layer.to_local(global_position)
	var map_pos = tile_map_layer.local_to_map(local_pos)
	
	# Pobieramy dane kafelka, na którym stoimy
	var tile_data = tile_map_layer.get_cell_tile_data(map_pos)
	
	if tile_data:
		# Odczytujemy nasze Custom Data o nazwie "tile_effect"
		var effect = tile_data.get_custom_data("tile_effect")
		
		# Reagujemy w zależności od efektu
		match effect:
			"mud":
				speed = base_speed * 0.5 # Błoto spowalnia o połowę
			"boost":
				speed = base_speed * 2.0 # Pole przyśpieszające
			"ice":
				# Tutaj w przyszłości możesz dodać logikę ślizgania
				speed = base_speed * 10.0

	else:
		# Gracz jest poza mapą (brak kafelka pod nogami)
		speed = base_speed
