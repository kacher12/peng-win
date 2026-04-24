extends TextureProgressBar

var timer: Timer

# --- ZMIENNE DO ANIMACJI LEWITACJI ---
var base_position: Vector2
@export var float_speed: float = 3.0       # Szybkość falowania
@export var float_amplitude: float = 10.0   # Zasięg falowania (zwiększyłem z 1.0 na 10.0, żeby efekt był widoczny)
@export var lerp_speed: float = 5.0        # Płynność ruchu
@export var temp_gradient: Gradient

func _ready() -> void:
	HeatSignals.on_heat_added.connect(_add_value)
	
	timer = Timer.new()
	timer.wait_time = 0.01
	timer.autostart = true 
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	# Zapisujemy pozycję startową
	base_position = position

func _add_value(amount):
	value += amount
	FX.squash_and_stretch(self)

func _on_timer_timeout() -> void:
	if value > 0:
		value -= 1
	else:
		timer.stop()

func _process(delta: float) -> void:
	# 1. Obliczamy czas dla funkcji sinus (używamy delta lub ticks)
	var time = Time.get_ticks_msec() / 1000.0
	
	# 2. Obliczamy tylko efekt falowania (sinusoida)
	var hover_offset = sin(time * float_speed) * float_amplitude
	
	# 3. Cel to pozycja bazowa + offset z falowania
	var target_y = base_position.y + hover_offset
	
	# 4. Płynne przemieszczenie do celu
	position.y = lerp(position.y, target_y, delta * lerp_speed)
	
	# Kolorowanie paska na podstawie Gradientu (jeśli jest przypisany)
	if temp_gradient != null:
		var percent = value / max_value
		self_modulate = temp_gradient.sample(percent)
