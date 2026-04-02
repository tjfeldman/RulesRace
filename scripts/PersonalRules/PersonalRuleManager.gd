extends Node
class_name PersonalRuleManager

"""
STATIC
"""
#Register the Personal Rule condition with an Array of players
#static var _registered_triggers: Dictionary[PersonalRules.Trigger, Array];
static var _registered_conditions: Dictionary[PersonalRules.Condition, Array];

static func register_personal_rule(player: Player):
	var rule = player.getPersonalRule();
	
	#register trigger to dictionary
	#var trigger_arr = _registered_triggers.get_or_add(rule.get_trigger(), []);
	#trigger_arr.append(player);
	
	#register condition to dictionary
	var condition_arr = _registered_conditions.get_or_add(rule.get_condition(), []);
	condition_arr.append(player);
	
"""
Class
"""
#This function checks to see if any players' personal rule will trigger on a roll and returns an array of actions
func check_roll_condition(roller: Player, roll: Variant) -> void:
	var player_arr;
	match roll:
		1:
			player_arr = _registered_conditions.get(PersonalRules.Condition.ROLL_ONE);
		2:
			player_arr = _registered_conditions.get(PersonalRules.Condition.ROLL_TWO);
		3:
			player_arr = _registered_conditions.get(PersonalRules.Condition.ROLL_THREE);
		"Jail":
			player_arr = _registered_conditions.get(PersonalRules.Condition.ROLL_PRISON);
		"Escape":
			player_arr = _registered_conditions.get(PersonalRules.Condition.ROLL_ESCAPE);
	#END MATCH
	
	#If the player_arr exists, then for each player in the arr we should check their trigger
	var actions: Array[PersonalRuleAction];
	if player_arr:	for player in player_arr: 
		var action = await _check_personal_rule_trigger(player, roller)
		if action: actions.append(action);
	
	#TODO: With multiple human players, this should ask all human players to acknowledge at same time then wait for all responses.
	if !actions.is_empty(): 
		for player in PlayerManager.getPlayers():
			await player.acknowledgePersonalRule(actions);
				
func _check_personal_rule_trigger(player: Player, causer: Player) -> PersonalRuleAction:
	var trigger = player.getPersonalRule().get_trigger();
	match trigger:
		PersonalRules.Trigger.SAME_SPACE:
			#Check the rule is triggered by someone other than the causer and the causer and player are in the same space
			if player != causer and player.is_sharing_space_with_player(causer):
				return await _find_rule_target(player);
	return null;
				
#Locate the target of the personal rule
func _find_rule_target(player: Player) -> PersonalRuleAction:
	var rule = player.getPersonalRule()
	match rule.get_target():
		PersonalRules.Target.I:
			var str = await _trigger_effect(rule.get_effect(), player);
			if !str.is_empty(): return PersonalRuleAction.new(player, player, str);
	return null;
				
func _trigger_effect(effect: PersonalRules.Effect, target: Player) -> String: 
	match effect:
		PersonalRules.Effect.MOVE_ONE:
			await target.movePlayerXSpaces(1);
			return "moves one space";
	return "";
