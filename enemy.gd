extends CharacterBody2D

var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(60.0,180.0)

var paused = true

@export var agent : NavigationAgent2D

func get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player")
	
func _ready():
	Bus.enemy_turn_ended.connect(on_enemy_turn_ended)
	Bus.enemy_turn_started.connect(on_enemy_turn_started)
	
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	agent.path_desired_distance = 4.0
	agent.target_desired_distance = 4.0
	
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func on_enemy_turn_started(time):
	movement_target_position = get_player().global_position
	paused = false
	
func on_enemy_turn_ended():
	paused = true
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Set target position
	movement_target_position = get_player().global_position
	
	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	agent.target_position = movement_target

func _physics_process(delta):
	if paused:
		return
	
	if agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()
