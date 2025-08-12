extends Node
@onready var PlayerData = preload("res://Scripts/player_data.gd").new()
@onready var NeighborUtils = preload("res://Scripts/neighbor_utils.gd").new()
signal random_pick_finished(picked_index)
signal phase_changed(new_phase)

var sweep_index := 0
var sweep_timer := Timer.new()
var sweep_order := []
var selected_player_index := -1
var overlay
var grid
var player_data
var neighbor_utils
var phase
var allowed_indices_holder
var highlight_index := 0
var highlight_timer := Timer.new()
var random_target_index := -1
var running_random_picker := false



func setup(_grid, _overlay, _player_data, _neighbor_utils, _allowed_indices_holder):
	grid = _grid
	overlay = _overlay
	player_data = _player_data
	neighbor_utils = _neighbor_utils
	allowed_indices_holder = _allowed_indices_holder

	highlight_timer.wait_time = 0.1
	highlight_timer.one_shot = false
	highlight_timer.timeout.connect(_on_highlight_timer_timeout)
	add_child(highlight_timer)
	
	sweep_timer.wait_time = 0.15
	sweep_timer.one_shot = false
	sweep_timer.timeout.connect(_on_sweep_step)
	add_child(sweep_timer)

func start_random_pick():
	selected_player_index = randi() % player_data.player_data.size()

	overlay.visible = true

	sweep_order.clear()
	for i in range(player_data.player_data.size()):
		sweep_order.append(i)

	sweep_index = 0
	sweep_timer.start()

func _on_sweep_step():
	if phase == "select_neighbor":  # Already in neighbor selection phase
		sweep_timer.stop()
		return
	for i in range(player_data.player_data.size()):
		var panel = grid.get_child(i)
		if panel.get_child_count() > 0:
			var btn = panel.get_child(0)
			btn.modulate = Color(0.2, 0.2, 0.2)

	var idx = sweep_order[sweep_index]
	var panel = grid.get_child(idx)
	if panel.get_child_count() > 0:
		var btn = panel.get_child(0)
		btn.modulate = player_data.player_data[idx].get("color", Color.WHITE)

	sweep_index += 1

	if sweep_index >= sweep_order.size():
		sweep_timer.stop()

		var pause_timer = Timer.new()
		pause_timer.wait_time = 0.5
		pause_timer.one_shot = true
		pause_timer.timeout.connect(_highlight_final)
		add_child(pause_timer)
		pause_timer.start()

func _highlight_final():
	
	for i in range(player_data.player_data.size()):
		var panel = grid.get_child(i)
		if panel.get_child_count() > 0:
			var btn = panel.get_child(0)
			btn.modulate = Color(0.2, 0.2, 0.2)

	var selected_panel = grid.get_child(selected_player_index)
	if selected_panel.get_child_count() > 0:
		var selected_btn = selected_panel.get_child(0)
		selected_btn.modulate = Color.YELLOW

	var neighbors = neighbor_utils.get_neighbors(selected_player_index, grid,PlayerData.player_data, player_data.GRID_WIDTH)
	for n in neighbors:
		var panel = grid.get_child(n)
		if panel.get_child_count() > 0:
			var btn = panel.get_child(0)
			btn.modulate = Color(0.4, 0.6, 1)
	allowed_indices_holder = neighbors  
	random_target_index = selected_player_index
	phase = "select_neighbor"
	emit_signal("phase_changed", "select_neighbor")
	emit_signal("random_pick_finished", selected_player_index)
	
	
func start_neighbor_selection(index):
	selected_player_index = index
	if index < 0 or index >= PlayerData.player_data.size():
		return

	for i in range(grid.get_child_count()):
		var panel = grid.get_child(i)
		if panel and panel.get_child_count() > 0:
			var btn = panel.get_child(0)
			if btn:
				if i < PlayerData.player_data.size():
					btn.modulate = PlayerData.player_data[i].get("color", Color.WHITE)
				else:
					btn.modulate = Color.WHITE

	var selected_panel = grid.get_child(index)
	if selected_panel and selected_panel.get_child_count() > 0:
		var selected_btn = selected_panel.get_child(0)
		if selected_btn:
			selected_btn.modulate = Color(1, 1, 0)

	allowed_indices_holder = NeighborUtils.get_neighbors(index, grid, PlayerData.player_data, PlayerData.GRID_WIDTH)

	for n in allowed_indices_holder:
		var panel = grid.get_child(n)
		if panel and panel.get_child_count() > 0:
			var btn = panel.get_child(0)
			if btn:
				btn.modulate = Color(0.4, 0.6, 1)
	phase = "select_neighbor"

func _on_highlight_timer_timeout():
	for i in range(player_data.size()):
		var panel = grid.get_child(i)
		if panel and panel.get_child_count() > 0:
			var btn = panel.get_child(0)
			btn.modulate = player_data[i].get("color", Color.WHITE)

	var panel = grid.get_child(highlight_index)
	if panel and panel.get_child_count() > 0:
		var btn = panel.get_child(0)
		btn.modulate = Color(1, 1, 1)

	highlight_index = (highlight_index + 1) % player_data.size()

func _on_stop_timer_timeout():
  
	highlight_timer.stop()

	for i in range(player_data.player_data.size()):
		var panel = grid.get_child(i)
		if panel and panel.get_child_count() > 0:
			var btn = panel.get_child(0)
			btn.modulate = player_data.player_data[i].get("color", Color.WHITE)

	var panel = grid.get_child(random_target_index)
	if panel and panel.get_child_count() > 0:
		var btn = panel.get_child(0)
		btn.modulate = Color(1, 1, 0)
	emit_signal("random_pick_finished", random_target_index)
	running_random_picker = false

func _finish_random_pick(selected_index: int):
	allowed_indices_holder.clear()
	allowed_indices_holder.append_array(
		neighbor_utils.get_neighbors(selected_index, grid.get_child_count())
	)

	emit_signal("random_pick_finished", selected_index)
	emit_signal("phase_changed", "select_neighbor") # tell GameManager to switch phase
