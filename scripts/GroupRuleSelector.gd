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
	
#checks if the player triggering a rule can activate the rule
static func verify_when(triggerPlayer: Player, whenRule: When):
	match whenRule:
		When.TURN:
			return PlayerManager.getCurrentTurnPlayer() == triggerPlayer;
		When.PRISON:
			return triggerPlayer.isInJail();
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

func random_rule():
	#select random group rules
	selectedWhenRule = whenGroupButtons[1];
	selectedTriggerRule = triggerGroupButtons[4];
	selectedEffectRule = effectGroupButtons[1];
	
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
