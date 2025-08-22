extends CenterContainer
class_name GroupRules

enum When {
	TURN,
	PRISON,
	LEADING,
	NONE
}

enum Trigger {
	ROLL_PRISON,
	ROLL_ONE,
	ROLL_TWO,
	ROLL_THREE,
	MOVES_PRISON,
	MOVE_BACK_TWO,
	DISCARD_TICKET,
	FORFEIT_DIE,
	NONE
}

enum Effect {
	MOVE_ONE,
	GAIN_TICKET,
	TRANSFER_TICKET,
	REROLL_DIE,
	MOVE_TO_PLAYER_AHEAD,
	MOVE_BACK,
	ROLL_SPECIAL_DIE,
	SEND_PLAYER_BACK_ONE,
	NONE
}

@export var whenGroupButtons: Array[WhenButton];
@export var triggerGroupButtons: Array[TriggerButton];
@export var effectGroupButtons: Array[EffectButton];

#May not need
var selectedWhenRule : WhenButton;
var selectedTriggerRule : TriggerButton;
var selectedEffectRule : EffectButton;

signal rules_updated(whenRule: RuleButton, triggerRule: RuleButton, effectRule: RuleButton);

func _ready() -> void:
	call_deferred("random_rule");

func random_rule():
	#select random group rules
	selectedWhenRule = whenGroupButtons[0];
	selectedTriggerRule = triggerGroupButtons[2];
	selectedEffectRule = effectGroupButtons[3];
	
	#toggle selected
	selectedWhenRule.button_pressed = true;
	selectedTriggerRule.button_pressed = true;
	selectedEffectRule.button_pressed = true;
	
	#disable all other buttons
	for btn in whenGroupButtons:
		btn.disable();
	for btn in triggerGroupButtons:
		btn.disable();
	for btn in effectGroupButtons:
		btn.disable();
			
	rules_updated.emit(selectedWhenRule, selectedTriggerRule, selectedEffectRule);
