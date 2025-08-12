extends Control

@onready var grid = $GridContainer
@onready var overlay = $Overlay
@onready var duel_popup = $DuelPopup
@onready var p1_label = $DuelPopup/BackgroundPanel/Player1Panel/Player1Label
@onready var p2_label = $DuelPopup/BackgroundPanel/Player2Panel/Player2Label
@onready var category_label = $DuelPopup/BackgroundPanel/CategoryLabel
@onready var random_button = $RandomPickButton
@onready var random_picker = $RandomPicker
@onready var player_data = PlayerData
@onready var AllowedIndicesHolder = preload("res://Scripts/AllowedIndicesHolder.gd")
@onready var PlayerData = preload("res://Scripts/player_data.gd").new()
@onready var NeighborUtils = preload("res://Scripts/neighbor_utils.gd").new()
@onready var DuelPopupHandler = preload("res://Scripts/duel_popup_handler.gd").new()
@onready var UIStyler = preload("res://Scripts/ui_styler.gd").new()
@onready var RandomPicker = preload("res://Scripts/random_picker.gd").new()
var selected_player_index := -1
var phase := "select_player"
var allowed_indices_holder

func _ready():
   

	add_child(PlayerData)
	add_child(NeighborUtils)
	add_child(DuelPopupHandler)
	add_child(UIStyler)
	add_child(RandomPicker)
	allowed_indices_holder= AllowedIndicesHolder.new().indices
	DuelPopupHandler.setup(p1_label,p2_label,category_label,duel_popup,duel_popup.get_node("StartButton"))
	UIStyler.style_random_button(random_button)
	RandomPicker.setup(grid, overlay, PlayerData, NeighborUtils, allowed_indices_holder)
	RandomPicker.connect("phase_changed", Callable(self, "_on_phase_changed"))
	DuelPopupHandler.connect("duel_started", Callable(self, "_on_duel_started"))

	var duel_popup = $DuelPopup
	duel_popup.duel_started.connect(_on_duel_started)

	# Remove existing children from the grid
	for child in grid.get_children():
		child.queue_free()

	# Add player buttons
	for i in range(PlayerData.player_data.size()):
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(180, 150)

		var btn = Button.new()
		var p = PlayerData.player_data[i]
		btn.text = "%s\n[%s]" % [p["name"], p["category"]]
		btn.custom_minimum_size = Vector2(170, 140)
		btn.modulate = PlayerData.player_data[i].get("color", Color.WHITE)
		btn.name = "PlayerButton_%d" % i
		btn.pressed.connect(_on_player_button_pressed.bind(i))

		panel.add_child(btn)
		grid.add_child(panel)
	random_button.pressed.connect(_on_random_pick_button_pressed)
	RandomPicker.connect("random_pick_finished", Callable(self, "_on_random_pick_finished"))


   
func _on_random_pick_finished(picked_index):
	selected_player_index = picked_index
	allowed_indices_holder = NeighborUtils.get_neighbors(
		selected_player_index,
		grid,
		PlayerData.player_data,
		PlayerData.GRID_WIDTH
	)
	phase = "select_neighbor"

func _on_player_button_pressed(index):
	if phase == "select_neighbor":
		if index in allowed_indices_holder:
			handle_neighbor_choice(index)
		else:
			print(allowed_indices_holder)
	else:
		selected_player_index = index
		
func _on_random_pick_button_pressed():
	RandomPicker.start_random_pick()
	

func _on_duel_started(p1, p2, category):
	BattleData.p1_name = p1
	BattleData.p2_name = p2
	BattleData.category = category
	var battle_scene = preload("res://Scenes/BattleArena.tscn").instantiate()
	get_tree().root.add_child(battle_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = battle_scene
	battle_scene.init_scene()

func handle_neighbor_choice(neighbor_index):
	var player1 = PlayerData.player_data[selected_player_index]
	var player2 = PlayerData.player_data[neighbor_index]
	var category = player2.get("category", "No category")
	DuelPopupHandler.show_duel_popup(player1, player2, category)
	
	
	var callback = Callable(self, "_on_duel_started")
	if not DuelPopupHandler.is_connected("duel_started", callback):
		DuelPopupHandler.connect("duel_started", callback)
	
	phase = "waiting_for_duel_start"
	allowed_indices_holder.clear()

func _on_phase_changed(new_phase: String):
	phase = new_phase

func _on_duel_popup_duel_started(player1_name: Variant, player2_name: Variant, category: Variant) -> void:
	var battle_scene = load("res://Scenes/BattleArena.tscn").instantiate()
	get_tree().root.add_child(battle_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = battle_scene

	battle_scene.start_battle(player1_name, player2_name, category)
