extends Button
class_name RuleButton

var description: String;

func _ready() -> void:
	description = self.text;

#if button is not pressed, disable it.	
func disable():
	if not self.button_pressed:
		self.disabled = true;

func enable():
	self.disabled = false;
