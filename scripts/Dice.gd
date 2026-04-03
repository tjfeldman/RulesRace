extends Sprite2D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer;
@onready var timer : Timer = $Timer;

@export var type : Dice.Type;

signal dice_has_rolled(type : Dice.Type, roll: Variant);

func rollDie():
	if timer.is_stopped():
		self.visible = true;
		animationPlayer.play("Roll");
		timer.start();

func _on_timer_timeout() -> void:
	#Get random value from the metadata of SIDES
	var rolledValue = get_meta("SIDES").pick_random();
	animationPlayer.play(str(rolledValue));
	#TODO: Create ENUM Value for Dice roll
	emit_signal("dice_has_rolled", type, rolledValue);

func _correct_die(special: bool):
	var isSpecialDie = type == Dice.Type.SPECIAL;
	return isSpecialDie == special;
