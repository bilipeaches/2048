extends Node

onready var timer: Timer = $SwipeTimeout
# 起点坐标
var start_position = Vector2()
# 终点坐标
var end_position = Vector2()
# 误差
var error = 50
# 桌面系统
var dos = ["X11", "Windows", "HTML5", "OSX"]
# 方向
var dirs = [
	"move_left",
	"move_right",
	"move_up",
	"move_down"
]
var now_dir = ""
# 手势信号
signal swipe_canceled()
signal swipe_finish(_dir)

func _ready():
	set_process(false)
	if OS.get_name() in dos:
		set_process(true)

# 检测键盘
func _process(delta):
	delta = delta
	if Input.is_action_just_pressed("ui_left"):
		finish(0)
	elif Input.is_action_just_pressed("ui_right"):
		finish(1)
	elif Input.is_action_just_pressed("ui_up"):
		finish(2)
	elif Input.is_action_just_pressed("ui_down"):
		finish(3)

# 起点
func _input(event):
	# 确认不是单纯点击
	if not event is InputEventScreenTouch:
		return
	# 初次点击
	if event.pressed:
		start_position = event.position
		timer.start()
	# 放开
	elif not timer.is_stopped():
		timer.stop()
		end_position = event.position
		Determine_the_direction()

# 判断方向
func Determine_the_direction():
	var index
	var x = start_position.x - end_position.x
	var y = start_position.y - end_position.y
	if x > error:
		index = 0
	elif -x > error:
		index = 1
	elif -y > error:
		index = 3
	elif y > error:
		index = 2
	else:
		return
	finish(index)

func finish(index):
	now_dir = dirs[index]
	emit_signal("swipe_finish", now_dir)

func _on_SwipeTimeout_timeout():
	emit_signal("swipe_canceled")
