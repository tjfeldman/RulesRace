extends Sprite2D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer;
@onready var timer : Timer = $Timer;
@onready var label : Label = $Label;

signal dice_has_rolled(roll: String);

#enum Values {ONE=1, TWO, THREE, JAIL, ESCAPE};
#var sides : Array[Values] = [Values.ONE, Values.TWO, Values.TWO, Values.THREE, Values.JAIL, Values.ESCAPE];
var sides : Array[String] = ["1", "2", "2", "3", "Jail", "Escape"];

func _unhandled_input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("ui_click") && timer.is_stopped()):
		animationPlayer.play("Roll");
		timer.start();
		label.visible = false;

func rollDice():
	var rolled = sides.pick_random();
	#animate die rolling and show rolled side
	#dieOutput.text = "Die Rolled: %s" % Values.find_key(rolled);
	return rolled;

func _on_timer_timeout() -> void:
	var rolledValue = sides.pick_random();
	animationPlayer.play(rolledValue);
	label.visible = true;
	emit_signal("dice_has_rolled", rolledValue);
