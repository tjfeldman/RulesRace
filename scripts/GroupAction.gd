extends Node
class_name GroupAction

enum CostType {
	NONE,
	MOVE_BACK,
	TICKET,
	DIE
}

var _action_cost_type: CostType;
var _action_effect: GroupRules.Effect;
var _action_when: GroupRules.When;

func _init(
	actionWhen: GroupRules.When = GroupRules.When.NONE,
	trigger_rule: GroupRules.Trigger = GroupRules.Trigger.NONE, 
	effect: GroupRules.Effect = GroupRules.Effect.NONE
) -> void:
	match trigger_rule:
		GroupRules.Trigger.MOVE_BACK_TWO:
			_action_cost_type = CostType.MOVE_BACK;
		GroupRules.Trigger.DISCARD_TICKET:
			_action_cost_type = CostType.TICKET;
		GroupRules.Trigger.FORFEIT_DIE:
			_action_cost_type = CostType.DIE;
		_:
			_action_cost_type = CostType.NONE;
	_action_effect = effect;
	_action_when = actionWhen;
	
func isGrantSpecialDie():
	return _action_effect == GroupRules.Effect.ROLL_SPECIAL_DIE;
	
func isGrantReroll():
	return _action_effect == GroupRules.Effect.REROLL_DIE;

func isValid():
	return _action_cost_type != CostType.NONE;
	
func canPay(player: Player):
	var canActivate = GroupRules.verify_when(player, _action_when);
	if canActivate and GroupRules.verify_player_can_use_rule(player, _action_effect):
		match _action_cost_type:
			CostType.MOVE_BACK:
				return !player.isInJail() and player.getBoardPosition() >= 2;
			CostType.TICKET:
				return player.getEscapeTicketCount() >= (2 if _action_effect == GroupRules.Effect.TRANSFER_TICKET else 1);
			CostType.DIE:
				#If the turn state is the start of turn, then the player can forfeit that die roll
				return ActionManager.getCurrentTurnState() == ActionManager.TurnState.START;
			_:
				return true;
	else:
		return false;
		
func getCostString():
	match _action_cost_type:
		CostType.MOVE_BACK:
			return "(-2 Spaces)";
		CostType.TICKET:
			return "(-1 Ticket)";
		CostType.DIE:
			return "(Forfeit Roll)";
		_:
			return "(Cost)";

func performAction(player: Player):
	#pay the cost, then perform effect
	match _action_cost_type:
		CostType.MOVE_BACK:
			player.movePlayerXSpaces(-2);
		CostType.TICKET:
			player.removeEscapeTicket();
		CostType.DIE:
			Events.emit_signal("forfeit_die_roll");
	Events.emit_signal("perform_rule_effect", player);
