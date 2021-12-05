extends Label

var width = 0
export var font_size = 60
export var rect_width = 180
onready var fd = load("res://Assets/Fonts/Font.ttf")

func _ready():
	width = rect_size.x

# 字体自适应
# warning-ignore:unused_argument
func _physics_process(delta):
	if rect_size.x > rect_width:
		font_size = font_size - 1
		var font = DynamicFont.new()
		font.size = font_size
		font.font_data = fd
		set("custom_fonts/font", font)
		rect_size.x = rect_width
