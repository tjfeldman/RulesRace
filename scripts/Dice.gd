extends Sprite2D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer;
@onready var timer : Timer = $Timer;
@onready var label : Label = $Label;

@export var type : Dice.Type;

signal dice_has_rolled(type : Dice.Type, roll: Variant);\

func _ready() -> void:
	Events.roll_die_action.connect(rollDie);

func rollDie(special: bool):
	if !_correct_die(special):
		self.visible = false;
	elif timer.is_stopped():
		self.visible = true;
		animationPlayer.play("Roll");
		timer.start();

func _on_timer_timeout() -> void:
	#Get random value from the metadata of SIDES
	var rolledValue = get_meta("SIDES").pick_random();
	animationPlayer.play(str(rolledValue));
	emit_signal("dice_has_rolled", type, rolledValue);

func _correct_die(special: bool):
	var isSpecialDie = type == Dice.Type.SPECIAL;
	return isSpecialDie == special;
