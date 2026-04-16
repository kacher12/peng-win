extends ProgressBar
var timer: Timer





func _ready() -> void: #zaczęło się!
	HeatSignals.on_heat_added.connect(_add_value)
	timer = Timer.new()
	timer.wait_time = 1.0 
	timer.autostart = true 
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
func _add_value(amount):
	value += amount
	FX.squash_and_stretch(self)
func _on_timer_timeout() -> void:

	if value > 0:
		value -= 1
	else:
		#skończyło się 
		timer.stop()
	
