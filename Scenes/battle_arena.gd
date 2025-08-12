extends Control

signal battle_finished(winner_name, loser_name)

var player1_name := ""
var player2_name := ""
var category := ""
var player1_time := 40
var player2_time := 40
var current_turn := 1

var animal_list: Array = []
var current_animal := ""
var current_image_index := 0

var timer := Timer.new()
var show_name_timer := Timer.new()

@onready var player1_timer_label: Label = $Player1TimerLabel
@onready var player2_timer_label: Label = $Player2TimerLabel
@onready var player1_name_label: Label = $Player1NameLabel
@onready var player2_name_label: Label = $Player2NameLabel
@onready var filename_label: Label = $filenameLabel
@onready var animal_image: TextureRect = $AnimalImage
@onready var say_button: Button = $SayButton
@onready var skip_button: Button = $SkipButton

func _ready():
    _set_big_font(player1_timer_label, 48)
    _set_big_font(player2_timer_label, 48)
    _set_big_font(player1_name_label, 48)
    _set_big_font(player2_name_label, 48)
    _set_big_font(filename_label, 42)
    _set_big_font(say_button.get_child(0), 36) # Label inside Button
    _set_big_font(skip_button.get_child(0), 36) # Label inside Button
    init_scene()
func _set_big_font(node: Control, size: int):
    if node == null:
        push_warning("Tried to set font on a null node.")
        return
    
    var font = ThemeDB.fallback_font
    if font:
        node.add_theme_font_override("font", font)
        node.add_theme_font_size_override("font_size", size)
    else:
        push_warning("Fallback font not found.")

func init_scene():
    # timers
    randomize()
    timer.wait_time = 1.0
    timer.one_shot = false
    timer.timeout.connect(_on_timer_tick)
    add_child(timer)

    show_name_timer.wait_time = 1.0
    show_name_timer.one_shot = true
    show_name_timer.timeout.connect(_on_show_name_timeout)
    add_child(show_name_timer)



    # buttons
    if say_button:
        say_button.pressed.connect(_on_say_pressed)
    if skip_button:
        skip_button.pressed.connect(_on_skip_pressed)

    # Start battle immediately
    start_battle(BattleData.p1_name, BattleData.p2_name, BattleData.category)

func start_battle(p1_name: String, p2_name: String, category_name: String):
    player1_name = p1_name
    player2_name = p2_name
    category = category_name

    player1_time = 40
    player2_time = 40
    current_turn = 1

    player1_name_label.text = player1_name
    player2_name_label.text = player2_name
    _update_timer_labels()

    _load_animal_list()
    current_image_index = 0
    _show_current_animal()
    timer.start()

func _on_timer_tick():
    if current_turn == 1:
        player1_time -= 1
        if player1_time <= 0:
            _end_battle(player2_name, player1_name)
    elif current_turn == 2:
        player2_time -= 1
        if player2_time <= 0:
            _end_battle(player1_name, player2_name)
    _update_timer_labels()

func _update_timer_labels():
    player1_timer_label.text = str(player1_time)
    player2_timer_label.text = str(player2_time)

func _load_animal_list():
    animal_list.clear()
    var path = "res://Assets/Images/מוצרי איפור"
    print("Loading images from:", path)
    var dir := DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        while true:
            var file = dir.get_next()
            if file == "":
                break
            var lower := file.to_lower()
            if lower.ends_with(".png") or lower.ends_with(".jpg") or lower.ends_with(".jpeg") or lower.ends_with(".webp"):
                var full_path = "%s/%s" % [path, file]
                print("Found image:", full_path)
                animal_list.append(full_path)
        dir.list_dir_end()
        animal_list.sort()
    else:
        push_error("Could not open battle category folder: %s" % path)

func _show_current_animal():
    if animal_list.is_empty():
        push_error("No images found in %s" % category)
        animal_image.texture = null
        return
    current_image_index = current_image_index % animal_list.size()
    current_animal = animal_list[current_image_index]
    var tex = load(current_animal)
    if tex:
        animal_image.texture = tex
    else:
        push_error("Failed to load texture: %s" % current_animal)

func _advance_image():
    if animal_list.is_empty():
        return
    current_image_index = (current_image_index + 1) % animal_list.size()
    _show_current_animal()

func _on_say_pressed():
    if animal_list.is_empty():
        return
    var file_name = current_animal.get_file().get_basename()
    filename_label.text = file_name
    filename_label.visible = true
    show_name_timer.stop()
    show_name_timer.wait_time = 1.0
    
    # Make sure it calls the normal say timeout
    if show_name_timer.timeout.is_connected(Callable(self, "_on_skip_name_timeout")):
        show_name_timer.timeout.disconnect(Callable(self, "_on_skip_name_timeout"))
    if not show_name_timer.timeout.is_connected(Callable(self, "_on_show_name_timeout")):
        show_name_timer.timeout.connect(Callable(self, "_on_show_name_timeout"))
    
    show_name_timer.start()

func _on_skip_pressed():
    if animal_list.is_empty():
        return
    var file_name = current_animal.get_file().get_basename()
    filename_label.text = file_name
    filename_label.visible = true
    show_name_timer.stop()
    show_name_timer.wait_time = 1.0
    
    # Make sure it calls skip timeout
    if show_name_timer.timeout.is_connected(Callable(self, "_on_show_name_timeout")):
        show_name_timer.timeout.disconnect(Callable(self, "_on_show_name_timeout"))
    if not show_name_timer.timeout.is_connected(Callable(self, "_on_skip_name_timeout")):
        show_name_timer.timeout.connect(Callable(self, "_on_skip_name_timeout"))
    
    show_name_timer.start()

func _on_skip_name_timeout():
    filename_label.visible = false
    _advance_image()
    # Restore normal say timeout
    if show_name_timer.timeout.is_connected(Callable(self, "_on_skip_name_timeout")):
        show_name_timer.timeout.disconnect(Callable(self, "_on_skip_name_timeout"))
    if not show_name_timer.timeout.is_connected(Callable(self, "_on_show_name_timeout")):
        show_name_timer.timeout.connect(Callable(self, "_on_show_name_timeout"))

func _on_show_name_timeout():
    filename_label.visible = false
    _advance_image()
    _switch_turn()

func _switch_turn():
    if current_turn == 1:
        current_turn = 2
    else:
        current_turn = 1

func _end_battle(winner, loser):
    timer.stop()
    print("Battle finished! Winner: %s, Loser: %s" % [winner, loser])
    emit_signal("battle_finished", winner, loser)
