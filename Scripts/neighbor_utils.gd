extends Node

func get_neighbors(index, grid, player_data, grid_width):
	var neighbors = []
	var row = index / grid_width
	var col = index % grid_width

	var deltas = [
		Vector2(0, -1),  # up
		Vector2(0, 1),   # down
		Vector2(-1, 0),  # left
		Vector2(1, 0)    # right
	]

	for delta in deltas:
		var new_row = row + int(delta.y)
		var new_col = col + int(delta.x)
		if new_row >= 0 and new_col >= 0 and new_col < grid_width:
			var neighbor_index = new_row * grid_width + new_col
			if neighbor_index < grid.get_child_count() and neighbor_index < player_data.size():
				neighbors.append(neighbor_index)

	return neighbors
