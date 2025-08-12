extends Node

var p1_label: Label
var p2_label: Label
var category_label: Label
var duel_popup: Window
var start_button: Button
signal duel_started(player1_name, player2_name, category)


func setup(p1_label_node, p2_label_node, category_label_node, popup_node, start_btn_node):
	p1_label = p1_label_node
	p2_label = p2_label_node
	category_label = category_label_node
	duel_popup = popup_node
	start_button = start_btn_node
	
	start_button.pressed.connect(_on_start_button_pressed)
	style_duel_popup()


func show_duel_popup(player1: Dictionary, player2: Dictionary, category: String) -> void:
	p1_label.text = player1.get("name", "Unknown")
	p2_label.text = player2.get("name", "Unknown")
	category_label.text =  category
	duel_popup.popup_centered()

func _on_start_button_pressed() -> void:
	print("Emitting duel_started with: ", p1_label.text, p2_label.text, category_label.text)
	duel_popup.hide()
	emit_signal("duel_started", p1_label.text, p2_label.text, category_label.text)

func style_duel_popup():
	duel_popup.min_size = Vector2(600, 400)
	duel_popup.title = "Battle Time!"

	# Style Player1Panel and Player2Panel
	var p1_panel = duel_popup.get_node_or_null("BackgroundPanel/Player1Panel")
	var p2_panel = duel_popup.get_node_or_null("BackgroundPanel/Player2Panel")

	for panel in [p1_panel, p2_panel]:
		if panel:
			panel.custom_minimum_size = Vector2(200, 200)
			panel.add_theme_color_override("panel", Color(0.15, 0.15, 0.15))

	# Style player labels
	if p1_label:
		p1_label.add_theme_font_size_override("font_size", 30)
		p1_label.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
		p1_label.align = 1
	if p2_label:
		p2_label.add_theme_font_size_override("font_size", 30)
		p2_label.add_theme_color_override("font_color", Color(0.4, 0.4, 1))
		p2_label.align = 1

	# Style category label
	if category_label:
		category_label.add_theme_font_size_override("font_size", 24)
		category_label.add_theme_color_override("font_color", Color(1, 1, 1))
		category_label.align = 1

	# Style VS label
	var vs_label = duel_popup.get_node_or_null("BackgroundPanel/VSLabel")
	if vs_label and vs_label is Label:
		vs_label.text = "VS"
		vs_label.add_theme_font_size_override("font_size", 64)
		vs_label.add_theme_color_override("font_color", Color(1, 1, 0))
		vs_label.align = 1
	else:
		push_warning("VSLabel not found in duel_popup!")

	# Optionally, style the start button here if needed
	if start_button:
		start_button.text = "Start Duel"
		start_button.custom_minimum_size = Vector2(180, 48)
