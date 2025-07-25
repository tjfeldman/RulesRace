extends Sprite2D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer;
@onready var timer : Timer = $Timer;
@onready var label : Label = $Label;

@export var type : Dice.Type;

#default to false and then set true
var canClick = false :
	set(value):
		canClick = value;
		label.visible = value;

signal dice_has_rolled(type : Dice.Type, roll: Variant);

func _unhandled_input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("ui_click") and timer.is_stopped() and canClick):
		animationPlayer.play("Roll");
		timer.start();
		canClick = false;

func _on_timer_timeout() -> void:
	#Get random value from the metadata of SIDES
	var rolledValue = get_meta("SIDES").pick_random();
	animationPlayer.play(str(rolledValue));
	emit_signal("dice_has_rolled", type, rolledValue);
