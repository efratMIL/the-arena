extends Node

func style_random_button(btn: Button):
	if not btn:
		return

	btn.text = "הגרל"
	btn.custom_minimum_size = Vector2(160, 48)

	var base_color = Color(0.16, 0.48, 0.85)
	var hover_color = Color(0.30, 0.62, 1.0)
	var pressed_color = Color(0.06, 0.36, 0.7)
	var text_color = Color(1, 1, 1)

	btn.modulate = base_color

	btn.connect("mouse_entered", Callable(self, "_on_random_hover_enter").bind(btn))
	btn.connect("mouse_exited", Callable(self, "_on_random_hover_exit").bind(btn))
	btn.connect("pressed", Callable(self, "_on_random_pressed").bind(btn))

	btn.set_meta("base_color", base_color)
	btn.set_meta("hover_color", hover_color)
	btn.set_meta("pressed_color", pressed_color)
	btn.set_meta("text_color", text_color)

func _on_random_hover_enter(btn):
	btn.modulate = btn.get_meta("hover_color")

func _on_random_hover_exit(btn):
	btn.modulate = btn.get_meta("base_color")

func _on_random_pressed(btn):
	btn.modulate = btn.get_meta("pressed_color")
	await btn.get_tree().create_timer(0.12).timeout
	btn.modulate = btn.get_meta("base_color")
