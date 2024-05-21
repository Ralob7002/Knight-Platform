extends CanvasModulate

# Constantes.
const time_color: Dictionary = {
	morning = Color.GRAY,
	afternoon = Color.ORANGE_RED,
	night = Color.DARK_SLATE_GRAY,
}

# Variáveis.
var time_index: int = 0:
	set(value):
		time_index = value % 3


func _ready():
	self.color = time_color.morning
	change_color()

func change_color():
	## Transição das cores de acordo com o tempo do mundo.
	var _next_color = time_color.values()[time_index]
	var _time = World.time.values()[time_index]
	
	var _tween = create_tween()
	_tween.tween_property(self, "color", _next_color, _time[0])
	_tween.tween_callback(func():
		_tween.kill()
		time_index += 1
		await get_tree().create_timer(_time[1]).timeout # Tempo que permanece naquele tempo.
		change_color())
