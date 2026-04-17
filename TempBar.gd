extends ProgressBar

var timer: Timer

# --- NOWE ZMIENNE DO ANIMACJI ---
var base_position: Vector2 # Zapiszemy tu oryginalną pozycję paska
var max_temp_offset: float 
@export var float_speed: float = 3.0       # Szybkość falowania góra-dół
@export var float_amplitude: float = 5.0   # Zasięg falowania (w pikselach)
@export var lerp_speed: float = 5.0        # Prędkość płynnego dojeżdżania do celu (im więcej, tym szybciej)
@export var temp_gradient: Gradient

func _ready() -> void: # zaczęło się!
	HeatSignals.on_heat_added.connect(_add_value)
	
	timer = Timer.new()
	timer.wait_time = 0.3
	timer.autostart = true 
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	# 1. Zapisujemy pozycję startową paska, by wiedzieć gdzie jest środek
	base_position = position
	
	#maksymalnie może przesunac sie o 30% w góre/ w dół
	max_temp_offset = size.y * 0.3 

func _add_value(amount):
	value += amount
	FX.squash_and_stretch(self)

func _on_timer_timeout() -> void:
	if value > 0:
		value -= 1
	else:
		# skończyło się 
		timer.stop()



func _process(delta: float) -> void:
	
	# Sprowadzamy wartość 0-100 do proporcji od -1.0 (zimno) do 1.0 (gorąco).
	var temp_ratio = (value - 50.0) / 50
	
	# W Godocie oś Y rośnie w dół. Więc jeśli gorąco (temp_ratio = 1), to chcemy
	# iść W GÓRĘ (ujemne Y). Dlatego dajemy minus przed temp_ratio.
	var target_temp_offset = -temp_ratio * max_temp_offset
	
	var time = Time.get_ticks_msec()/1000 # to może ZNISZCZYĆ optymalność
	
	# Time.get_ticks_msec() daje nam ciągły czas gry. Sinus zamienia to w falę.
	
	var hover_offset = sin(time * float_speed) * float_amplitude
	
	# KROK 3: Łączymy pozycję bazową, wychylenie temperatury i lewitację.
	var target_y = base_position.y + target_temp_offset + hover_offset
	
	# KROK 4: Płynnie przesuwamy pasek (lerp działa jak niekończący się Tween).
	position.y = lerp(position.y, target_y, delta * lerp_speed)
	if temp_gradient != null:
		var percent = value / max_value
		self_modulate = temp_gradient.sample(percent)
