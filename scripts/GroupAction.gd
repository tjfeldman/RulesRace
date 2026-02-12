extends Node
class_name GroupAction

enum CostType {
	NONE,
	MOVE_BACK
}

var action_cost_type: CostType;
var action_cost_value: int;
var action_effect: GroupRules.Effect;

func _init(trigger_rule: GroupRules.Trigger = GroupRules.Trigger.NONE, effect: GroupRules.Effect = GroupRules.Effect.NONE):
	match trigger_rule:
		GroupRules.Trigger.MOVE_BACK_TWO:
			action_cost_type = CostType.MOVE_BACK;
			action_cost_value = 2;
		_:
			action_cost_type = CostType.NONE;
			action_cost_value = 0;
	action_effect = effect;

func isValid():
	return action_cost_type != CostType.NONE;
	
func canPay(player: Player):
	var canBenefit = GroupRules.verify_player_can_use_rule(player, action_effect);
	if canBenefit:
		match action_cost_type:
			CostType.MOVE_BACK:
				return !player.isInJail() and player.getBoardPosition() >= action_cost_value;
			_:
				return true;
	else:
		return false;
		
func getCostString():
	match action_cost_type:
		CostType.MOVE_BACK:
			return "(-%d Spaces)" % action_cost_value;
		_:
			return "(Cost)"

func performAction(scene: Node2D, player: Player):
	#pay the cost, then perform effect
	match action_cost_type:
		CostType.MOVE_BACK:
			player.movePlayerXSpaces(-1*action_cost_value);
	Events.emit_signal("perform_rule_effect", scene, player);
