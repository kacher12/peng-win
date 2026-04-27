extends CharacterBody2D

# --- PODSTAWOWY RUCH ---
@export var speed = 400.0
@export var normal_steering = 60.0 
@export var hard_speed_cap = 1800.0    # NOWE: Maksymalna możliwa prędkość w grze

# --- LÓD (ICE) ---
@export var max_ice_speed = 900.0      
@export var ice_acceleration = 450.0   
@export var momentum_decay = 700.0     # Bazowa wartość hamowania

# --- DASH ---
@export var dash_speed = 1200.0
@export var dash_steering = 5.0 
@export var min_dash_duration = 0.2
@export var max_dash_duration = 0.35

# --- MECHANIKI ODBIĆ (BOUNCING) ---
@export var ice_edge_bounce_multiplier: float = 0.6 
@export var wall_bounce_multiplier: float = 0.85    
@export var bounce_duration: float = 0.35           
@export var bounce_steering: float = 1.5            

# --- EFEKT SZLAKU (MOMENTUM 2D) ---
@export var normal_trail_color: Color = Color(1.0, 1.0, 1.0, 0.3)      
@export var light_ice_trail_color: Color = Color(0.6, 0.85, 1.0, 0.5)  
@export var ice_trail_color: Color = Color(0.2, 0.6, 1.0, 0.6)         
@export var dash_trail_color: Color = Color(1.0, 1.0, 1.0, 0.6)        
@export var ghost_spawn_rate: float = 0.05                        
@export var ghost_life_time: float = 0.35                         

# --- EFEKT SZLAKU (DASH 3D) ---
@export var sub_viewport_container: SubViewportContainer
@export var sub_viewport: SubViewport
@export var dash_trail_opacity: float = 0.5
@export var dash_ghost_rate: float = 0.03
@export var dash_ghost_lifetime: float = 0.4

# --- MAPA ---
@export var tile_map_layer: TileMapLayer

var is_dashing = false
var dash_timer = 0.0
var ghost_timer = 0.0
var bounce_timer = 0.0 
var is_on_ice = false 
var was_on_ice = false 

@onready var base_speed = speed 
@onready var base_normal_steering = normal_steering 
@onready var base_dash_speed = dash_speed       
@onready var base_dash_steering = dash_steering 

func get_input(delta, terrain_speed):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if is_dashing:
		if input_direction != Vector2.ZERO:
			var target_velocity = input_direction * dash_speed
			velocity = velocity.lerp(target_velocity, dash_steering * delta)
		return 
		
	if was_on_ice and not is_on_ice:
		if input_direction != Vector2.ZERO and velocity.normalized().dot(input_direction.normalized()) < -0.4:
			speed = max_ice_speed * ice_edge_bounce_multiplier
			velocity = input_direction * speed
			return 

	if is_on_ice:
		var dot = 1.0
		if velocity.length() > 50 and input_direction != Vector2.ZERO:
			dot = velocity.normalized().dot(input_direction.normalized())
			
		if input_direction != Vector2.ZERO and dot > 0.8:
			speed = move_toward(speed, max_ice_speed, ice_acceleration * delta)
		else:
			speed = move_toward(speed, terrain_speed, ice_acceleration * 2.0 * delta)
			
		var target_velocity = input_direction * speed
		velocity = velocity.lerp(target_velocity, normal_steering * delta)
	else:
		# --- NOWA LOGIKA DYNAMICZNEGO MOMENTUM ---
		if speed > terrain_speed:
			# Obliczamy jak bardzo prędkość przekracza bazową
			# Jeśli lecisz 1800, a baza to 400, mnożnik hamowania wyniesie 4.5x
			var decay_multiplier = speed / terrain_speed
			speed = move_toward(speed, terrain_speed, momentum_decay * decay_multiplier * delta)
		else:
			speed = terrain_speed 
			
		var target_velocity = input_direction * speed
		
		var current_steering = normal_steering
		if bounce_timer > 0:
			current_steering = bounce_steering
		elif speed > terrain_speed + 100:
			current_steering = normal_steering * 0.1 
			
		velocity = velocity.lerp(target_velocity, current_steering * delta)
	
	# Globalne ograniczenie prędkości
	speed = clamp(speed, 0.0, hard_speed_cap)

func _physics_process(delta):
	was_on_ice = is_on_ice
	if bounce_timer > 0:
		bounce_timer -= delta
	
	var current_terrain_speed = check_current_tile()
	get_input(delta, current_terrain_speed)
	
	if Input.is_action_just_pressed("dash") and not is_dashing:
		start_dash()
	
	if is_dashing:
		dash_timer += delta 
		ghost_timer += delta 
		if ghost_timer >= dash_ghost_rate:
			spawn_3d_dash_ghost()
			ghost_timer = 0.0 
		if dash_timer >= max_dash_duration:
			stop_dash()
		elif dash_timer >= min_dash_duration and not Input.is_action_pressed("dash"):
			stop_dash()
	else:
		if velocity.length() > 10:
			ghost_timer += delta 
			if ghost_timer >= ghost_spawn_rate:
				spawn_trail_ghost(false) 
				ghost_timer = 0.0 
		else:
			ghost_timer = ghost_spawn_rate 
	
	var pre_velocity = velocity
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == tile_map_layer:
			var normal = collision.get_normal()
			var hit_point = collision.get_position() - normal * 2.0
			var map_pos = tile_map_layer.local_to_map(tile_map_layer.to_local(hit_point))
			var tile_data = tile_map_layer.get_cell_tile_data(map_pos)
			
			if tile_data:
				var effect = tile_data.get_custom_data("tile_effect")
				if effect == "wall":
					if is_dashing: stop_dash()
					if pre_velocity.length() > 50 and bounce_timer <= 0:
						var bounce_dir = pre_velocity.bounce(normal).normalized()
						var input_dir = Input.get_vector("left", "right", "up", "down")
						if input_dir != Vector2.ZERO:
							var custom_bounce = (bounce_dir + input_dir * 1.5).normalized()
							if custom_bounce.dot(normal) > 0.1:
								bounce_dir = custom_bounce
						
						speed = clamp(pre_velocity.length() * wall_bounce_multiplier, base_speed, hard_speed_cap)
						velocity = bounce_dir * speed
						bounce_timer = bounce_duration
					break

func start_dash():
	var dash_direction = Input.get_vector("left", "right", "up", "down")
	if dash_direction == Vector2.ZERO: return
	is_dashing = true
	dash_timer = 0.0 
	ghost_timer = 0.0
	velocity = dash_direction * dash_speed
	get_tree().call_group("trail_ghosts", "queue_free")

func stop_dash():
	is_dashing = false
	if is_on_ice:
		speed = velocity.length() * 0.9 

func check_current_tile() -> float:
	var terrain_speed = base_speed
	is_on_ice = false
	normal_steering = base_normal_steering
	dash_steering = base_dash_steering
	dash_speed = base_dash_speed
	if not tile_map_layer: return terrain_speed 
	var local_pos = tile_map_layer.to_local(global_position)
	var map_pos = tile_map_layer.local_to_map(local_pos)
	var tile_data = tile_map_layer.get_cell_tile_data(map_pos)
	if tile_data:
		var effect = tile_data.get_custom_data("tile_effect")
		match effect:
			"mud": terrain_speed = base_speed * 0.5 
			"boost": terrain_speed = base_speed * 2.0 
			"ice":
				is_on_ice = true
				normal_steering = 1.5 
				dash_steering = base_dash_steering * 0.2 
				dash_speed = base_dash_speed * 0.70
	return terrain_speed

func spawn_trail_ghost(is_dash_ghost: bool = false):
	var sprite = $Sprite2D 
	var ghost = Sprite2D.new()
	get_tree().current_scene.add_child(ghost)
	ghost.add_to_group("trail_ghosts")
	ghost.global_position = sprite.global_position
	ghost.global_scale = sprite.global_scale
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.offset = sprite.offset       
	ghost.centered = sprite.centered   
	ghost.z_index = z_index - 1 
	var current_color = normal_trail_color
	if is_dash_ghost:
		current_color = dash_trail_color
	else:
		if is_on_ice:
			current_color = ice_trail_color
		elif speed > base_speed:
			var extra_speed = speed - base_speed
			var max_extra = hard_speed_cap - base_speed # Skalowanie szlaku do nowego limitu
			var ratio = clamp(extra_speed / max_extra, 0.0, 1.0) 
			if ratio > 0.5:
				var sub_ratio = (ratio - 0.5) * 2.0
				current_color = light_ice_trail_color.lerp(ice_trail_color, sub_ratio)
			else:
				var sub_ratio = ratio * 2.0
				current_color = normal_trail_color.lerp(light_ice_trail_color, sub_ratio)
	ghost.modulate = current_color
	var tween = ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, ghost_life_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(ghost.queue_free)

func spawn_3d_dash_ghost():
	if not sub_viewport_container or not sub_viewport: return
	var texture = sub_viewport.get_texture()
	var image = texture.get_image()
	if image.is_empty(): return 
	image.flip_y()
	var static_texture = ImageTexture.create_from_image(image)
	var ghost = TextureRect.new()
	ghost.texture = static_texture
	ghost.global_position = sub_viewport_container.global_position
	ghost.scale = sub_viewport_container.scale
	ghost.size = sub_viewport_container.size
	ghost.modulate.a = dash_trail_opacity
	ghost.z_index = z_index - 1
	ghost.add_to_group("trail_ghosts")
	get_tree().current_scene.add_child(ghost)
	var tween = ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, dash_ghost_lifetime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(ghost.queue_free)
