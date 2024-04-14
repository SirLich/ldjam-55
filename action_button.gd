@tool

extends VBoxContainer

@export var action : String
@export var title : String
@export var need_charges : int
@export var charges : int

@export var chip_container : HBoxContainer




@export var chip : PackedScene
@export var button : Button

@export var unfilled_texture : Texture2D
@export var filled_texture :Texture2D

func set_chip_filled(c, val):
	if val:
		c.texture = filled_texture
	else:
		c.texture = unfilled_texture

func recharge_all():
	set_charges(need_charges)
	
func _ready():
	Bus.recharge_all.connect(recharge_all)
	Bus.perform_action.connect(on_action_performed)
	Bus.enemy_turn_ended.connect(on_enemy_turn_ended)
	
	for i in need_charges:
		var new_chip = chip.instantiate()
		chip_container.add_child(new_chip)
			
	set_charges(charges)

func on_enemy_turn_ended():
	increment_charges()
	
func increment_charges():
	set_charges(charges + 1)

func decriment_charges():
	set_charges(charges - 1)
	
func set_charges(num):
	if num > need_charges:
		return
	
	if num < need_charges:
		button.disabled = true
	if num == need_charges:
		button.disabled = false
		
	charges = num
	
	for i in need_charges:
		set_chip_filled(chip_container.get_child(i), i < charges)
	
	
func on_action_performed(in_action):
	if Player.PlayerAction.get(action) == in_action:
		set_charges(0)
	
func _process(delta):
	button.text = title
	
func _on_move_button_pressed():
	get_tree().get_first_node_in_group("player").set_action(action)
