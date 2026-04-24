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

#DASH TRAIL
@export var  trail_color: Color = Color(0.475, 0.722, 1.0, 0.6)
@export var ghost_spawn_rate: float = 0.03
@export var ghost_life_time: float = 0.4
var ghost_timer: float = 0.0

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
		ghost_timer += delta
		
		# --- NOWE: Tworzenie szlaku ---
	if ghost_timer >= ghost_spawn_rate:
		spawn_trail_ghost()
		ghost_timer = 0.0 # Resetujemy licznik po stworzeniu klona
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
	ghost_timer = 0.0
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
		

func spawn_trail_ghost():
	var sprite = $Sprite2D 
	var ghost = Sprite2D.new()
	
	# KROK 1: Najpierw dodajemy ducha do sceny! 
	# Dzięki temu Godot poprawnie obliczy jego globalne współrzędne.
	get_tree().current_scene.add_child(ghost)
	
	# KROK 2: Kopiujemy pozycję i skalę (używamy global_scale na wypadek, gdybyś skalował gracza)
	ghost.global_position = sprite.global_position
	ghost.global_scale = sprite.global_scale
	
	# KROK 3: Kopiujemy wygląd i (BARDZO WAŻNE) offsety
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.offset = sprite.offset       # <-- NOWE: Kopiuje przesunięcie środka obrazka
	ghost.centered = sprite.centered   # <-- NOWE: Kopiuje ustawienie centrowania
	
	# KROK 4: Efekty wizualne
	ghost.z_index = z_index - 1 
	ghost.modulate = trail_color
	
	# TWEEN: Płynne zanikanie
	var tween = ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, ghost_life_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(ghost.queue_free)
