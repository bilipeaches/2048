extends Panel

"""
x -> 88
y -> 80
"""
# 数字
var number = 2
# 特殊数字
var left_numbers = [0, 4, 8, 12]
var right_numbers = [3, 7, 11, 15]
var up_numbers = [0, 1, 2, 3]
var down_numbers = [12, 13, 14, 15]
# 位置
var position
# 正在移动
var is_moving = false
var move_to_pos
# 立即移动
var now = false
onready var game = get_node("../../..")
onready var tween: Tween = game.get_node("Tween")
# 颜色
var colors = {
	2:Color("#A9F3F2"),
	4:Color("#00DCF4"),
	8:Color("#00A7F5"),
	16:Color("#73A0FD"),
	32:Color("#3478DB"),
	64:Color("#2F5093"),
	128:Color("#0641E1"),
	256:Color("#6155DB"),
	512:Color("#A57FEB"),
	1024:Color("#B063FF"),
	2048:Color("#9E00E9"),
	4096:Color("#8900EE"),
	8192:Color("#7A00F8"),
	16384:Color("#6F00FC"),
	32768:Color("#536DFE"),
	65536:Color("#3490FF"),
	131072:Color("#0C87C3")
}

# 设置颜色
func set_number(num: int):
	number = num
	$AnimationPlayer.play("set_number")
	var sf = StyleBoxFlat.new()
	sf.bg_color = colors[num]
	sf.shadow_color = Color(0, 0, 0, 0.2)
	sf.shadow_size = 2
	sf.shadow_offset = Vector2(2, 2)
	set("custom_styles/panel", sf)
	$Number.text = str(num)

# 移动
func move(dir):
	is_moving = false
	# 左边
	if "left" in dir and position in left_numbers:
		return
	elif "left" in dir:
		# 检查是否有空位
		var now_pos = rect_position.x
		var is_ok = false
		while now_pos >= 30:
			now_pos = now_pos - 88
			if now_pos >= 30:
				if game.can_in(Vector2(now_pos, rect_position.y), self):
					is_ok = true
					if now:
						now = false
						break
				else:
					now_pos = now_pos + 88
					break
			else:
				now_pos = now_pos + 88
				break
		if is_ok:
			move_to(now_pos, "x")
			return
		return
	# 右边
	if "right" in dir and position in right_numbers:
		return
	elif "right" in dir:
		var now_pos = rect_position.x
		var is_ok = false
		while now_pos <= 294:
			now_pos = now_pos + 88
			if now_pos <= 294:
				if game.can_in(Vector2(now_pos, rect_position.y), self):
					is_ok = true
					if now:
						now = false
						break
				else:
					now_pos = now_pos - 88
					break
			else:
				now_pos = now_pos - 88
				break
		if is_ok:
			move_to(now_pos, "x")
			return
		return
	# 上边
	if "up" in dir and position in up_numbers:
		return
	elif "up" in dir:
		# 检查是否有空位
		var now_pos = rect_position.y
		var is_ok = false
		while now_pos >= 176:
			now_pos = now_pos - 80
			if now_pos >= 176:
				if game.can_in(Vector2(rect_position.x, now_pos), self):
					is_ok = true
					if now:
						now = false
						break
				else:
					now_pos = now_pos + 80
					break
			else:
				now_pos = now_pos + 80
				break
		if is_ok:
			move_to(now_pos, "y")
			return
		return
	# 下边
	if "down" in dir and position in down_numbers:
		return
	elif "down" in dir:
		var now_pos = rect_position.y
		var is_ok = false
		while now_pos <= 416:
			now_pos = now_pos + 80
			if now_pos <= 416:
				if game.can_in(Vector2(rect_position.x, now_pos), self):
					is_ok = true
					if now:
						now = false
						break
				else:
					now_pos = now_pos - 80
					break
			else:
				now_pos = now_pos - 80
				break
		if is_ok:
			move_to(now_pos, "y")
			return
		return

# 开始移动
func move_to(pos, xy):
	is_moving = true
	if xy == "x":
		position = game.pps[Vector2(pos, rect_position.y)]
		move_to_pos = Vector2(pos, rect_position.y)
# warning-ignore:return_value_discarded
		tween.interpolate_property(self, "rect_position:x", rect_position.x, pos, 0.1
	, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	else:
		position = game.pps[Vector2(rect_position.x, pos)]
		move_to_pos = Vector2(rect_position.x, pos)
# warning-ignore:return_value_discarded
		tween.interpolate_property(self, "rect_position:y", rect_position.y, pos, 0.1
	, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	name = str(position)
# warning-ignore:return_value_discarded
	tween.start()
	game.flush()

func _ready():
	if randi() % 2:
		number = 4
	set_number(number)
