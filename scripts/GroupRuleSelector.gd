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

@export var whenGroup: ButtonGroup;
@export var triggerGroup: ButtonGroup;
@export var effectGroup: ButtonGroup;

@onready var same_rule_warning_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SameRuleWarningLabel
@onready var incomplete_rule_warning_label: Label = $PanelContainer/MarginContainer/VBoxContainer/IncompleteRuleWarningLabel
@onready var confirm_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ConfirmBtn
func isEditing(): return confirm_btn.visible;

var currentWhenRule : WhenButton;
var currentTriggerRule : TriggerButton;
var currentEffectRule : EffectButton;

signal rules_updated(whenRule: RuleButton, triggerRule: RuleButton, effectRule: RuleButton);

func _ready() -> void:
	#call_deferred("random_rule");
	pass;

func set_for_editing():
	self.visible = true;
	for btn in whenGroup.get_buttons():
		btn.enable();
	for btn in triggerGroup.get_buttons():
		btn.enable();
	for btn in effectGroup.get_buttons():
		btn.enable();
	confirm_btn.visible = true;
	
func set_for_display():
	#disable all other buttons
	for btn in whenGroup.get_buttons():
		btn.disable();
	for btn in triggerGroup.get_buttons():
		btn.disable();
	for btn in effectGroup.get_buttons():
		btn.disable();
	same_rule_warning_label.visible = false;
	incomplete_rule_warning_label.visible = false;
	confirm_btn.visible = false;
	
#checks if the player triggering a rule can activate the rule
static func verify_when(triggerPlayer: Player, whenRule: When):
	match whenRule:
		When.TURN:
			return PlayerManager.getCurrentTurnPlayer() == triggerPlayer;
		When.PRISON:
			return triggerPlayer.isInJail();
		When.LEADING:
			return PlayerManager.getLeadingPlayer() == triggerPlayer;
		_:
			return false;
	
static func verify_player_can_use_rule(affectedPlayer: Player, effectRule: Effect):
	#if player has made it to the goal, they cannot benefit from the effect
	if affectedPlayer.hasFinished(): return false;
	
	match effectRule:
		Effect.MOVE_ONE:
			return !affectedPlayer.isInJail();
		Effect.MOVE_TO_PLAYER_AHEAD:
			return !affectedPlayer.isInJail() and PlayerManager.getPlayerAhead(affectedPlayer);
		Effect.MOVE_BACK:
			return !affectedPlayer.isInJail() and affectedPlayer.getBoardPosition() > 0;
		Effect.SEND_PLAYER_BACK_ONE:
			#we can't move players who are at the start, are currently in jail, or has finished the race
			return PlayerManager.getListOfAllOtherPlayers(affectedPlayer).filter(func(p): return p.getBoardPosition() > 0 and not p.isInJail() and not p.hasFinished());
		Effect.TRANSFER_TICKET:
			return affectedPlayer.hasEscapeTicket();
		Effect.REROLL_DIE, Effect.ROLL_SPECIAL_DIE:
			#dice can only be used on player's turn
			return PlayerManager.getCurrentTurnPlayer() == affectedPlayer;
		_:
			return true;

#TODO: Better logic as not all rules are created equal
func random_rule():
	#select random group rules
	var sameWhen = true;
	var sameTrigger = true;
	var sameEffect = true;
	
	var selectedWhen;
	var selectedTrigger;
	var selectedEffect;
	
	#pick random rules and make sure it is not the same existing rule
	while sameWhen and sameTrigger and sameEffect:
		selectedWhen = whenGroup.get_buttons().pick_random();
		selectedTrigger = triggerGroup.get_buttons().pick_random();
		selectedEffect = effectGroup.get_buttons().pick_random();
		
		sameWhen = selectedWhen == currentWhenRule;
		sameTrigger = selectedTrigger == currentTriggerRule;
		sameEffect = selectedEffect == currentEffectRule;
	
	currentWhenRule = selectedWhen;
	currentTriggerRule = selectedTrigger;
	currentEffectRule = selectedEffect;
	
	#toggle selected
	currentWhenRule.button_pressed = true;
	currentTriggerRule.button_pressed = true;
	currentEffectRule.button_pressed = true;
	
	set_for_display();			
	rules_updated.emit(currentWhenRule, currentTriggerRule, currentEffectRule);

func _on_confirm_btn_pressed() -> void:
	#verify that the selected btns are not the same ones already selected
	var selectedWhen = whenGroup.get_pressed_button();
	var selectedTrigger = triggerGroup.get_pressed_button();
	var selectedEffect = effectGroup.get_pressed_button();
	
	var sameWhen = selectedWhen == currentWhenRule;
	var sameTrigger = selectedTrigger == currentTriggerRule;
	var sameEffect = selectedEffect == currentEffectRule;
	
	#verify that the player has selected a rule in each category
	if selectedWhen == null or selectedTrigger == null or selectedEffect == null:
		incomplete_rule_warning_label.visible = true;
		same_rule_warning_label.visible = false;
	#verify that the rule is not the same already in effect
	elif sameWhen and sameTrigger and sameEffect:
		same_rule_warning_label.visible = true;
		incomplete_rule_warning_label.visible = false;
	else:
		#update the current rule
		currentWhenRule = selectedWhen;
		currentTriggerRule = selectedTrigger;
		currentEffectRule = selectedEffect;
		
		self.visible = false;
		set_for_display();
		rules_updated.emit(currentWhenRule, currentTriggerRule, currentEffectRule);
