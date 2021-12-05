extends Control

# 能否移动
var can_move = true
# 可用列表
var can_use = []
# pos对应
var pps = {}
var using = false
var children_names = []
# Score
var score = 0
onready var score_text: Label = $Main/Up/Score/ScoreText
# 最佳分数
var best_score = 0
# 2048
onready var _2048 = load("res://Scenes/2048.tscn")
onready var game_box: Control = $Main/GameBox
onready var game_position: Control = $Main/GamePosition

# H5定位
func _process(delta):
	delta = delta
	$Main.rect_position.x = OS.get_real_window_size().x / 2 - 382 / 2

# 准备游戏
func _ready():
	set_process(false)
	if OS.get_name() == "Android":
# warning-ignore:return_value_discarded
		OS.request_permissions()
	elif OS.get_name() == "HTML5":
		set_process(true)
	# 获取最佳分数
	if !EasySave.has_file("2048.data"):
		EasySave.save_data_encryptioned_auto("2048.data", {"best":0})
	best_score = EasySave.load_data_encryptioned_auto("2048.data")["best"]
	$Main/Up/Top/Top.text = "Top:" + str(best_score)
	for i in 16:
		var pos = game_position.get_child(i).position
		pps[pos] = i
	new_game()
	yield(get_tree().create_timer(1), "timeout")
	_new()

func _new():
	# 生成2048
	if randi() % 2:
		new_block()
	new_block()

# 新游戏
func new_game():
	randomize()
	use_re()

func use_re():
	can_use = []
	for i in 16:
		can_use.append(i)

# 新方块
func new_block():
	var index = get_block_position()
	# GameOver返回-1
	if index >= 0:
		var _pos = game_position.get_child(index).position
		var _block = _2048.instance()
		game_box.add_child(_block)
		_block.rect_position = _pos
		# 变量
		_block.position = index
		_block.name = str(index)

# 获取位置
func get_block_position():
	if len(can_use) != 0:
		var index = randi() % len(can_use)
		var val = can_use[index]
		can_use.remove(index)
		return val
	else:
		GameOver()
		return -1

# 获取位置2048
func get_pos_block(pos):
	return game_box.get_node(str(pps[pos]))

# 位置是否被占用
func can_in(pos, _block):
	flush()
	var index = pps[pos]
	if index in can_use:
		return true
	var block = get_pos_block(pos)
	if block.number == _block.number:
		# 相加
		_block.number = _block.number * 2
		score += _block.number
		# 判断最高分
		if score > best_score:
			EasySave.save_data_encryptioned_auto("2048.data", {"best":score})
			best_score = score
			$Main/Up/Top/Top.text = "Top:" + str(best_score)
		score_text.text = str(score)
		_block.set_number(_block.number)
		_block.move_to_pos = pos
		block.queue_free()
		children_names.erase(block.position)
		return true
	elif block.is_moving and pos != block.move_to_pos:
		_block.now = true
		return true
	else:
		return false

# 游戏结束
func GameOver():
	print("GameOver!")

# 关于
func _on_About_pressed():
	$AnimationPlayer.play("About")

func _on_AboutClose_pressed():
	$AnimationPlayer.play_backwards("About")

# 刷新
func flush():
	use_re()
	for i in game_box.get_children():
		i.name = str(i.position)
		can_use.erase(i.position)
	return true

# 滑动判断
func _on_SwipeDetector_swipe_finish(_dir):
	if can_move and not using:
		using = true
		var block_children = $Main/GameBox.get_children()
		children_names.clear()
		for i in block_children:
			children_names.append(i.position)
		# 右边或下倒叙排列
		if _dir in ["move_down", "move_right"]:
			children_names.invert()
		else:
			children_names.sort()
		for child in children_names:
			game_box.get_node(str(child)).move(_dir)
		yield(get_tree().create_timer(0.1 * len(children_names)), "timeout")
		flush()
		_new()
		using = false
	else:
		can_move = true

func _on_SwipeDetector_swipe_canceled():
	can_move = false

# 重来
func _on_Re_pressed():
	$AnimationPlayer.play_backwards("Start")
	yield($AnimationPlayer, "animation_finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Game.tscn")
