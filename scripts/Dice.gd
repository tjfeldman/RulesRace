extends Sprite2D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer;
@onready var timer : Timer = $Timer;
@onready var label : Label = $Label;

var canClick = true :
	set(value):
		canClick = value;
		label.visible = value;

signal dice_has_rolled(roll: Variant);

const SIDES : Array[Variant] = [1, 2, 2, 3, "Jail", "Escape"];	

func _unhandled_input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("ui_click") and timer.is_stopped() and canClick):
		animationPlayer.play("Roll");
		timer.start();
		canClick = false;

func _on_timer_timeout() -> void:
	var rolledValue = SIDES.pick_random();
	animationPlayer.play(str(rolledValue));
	emit_signal("dice_has_rolled", rolledValue);
