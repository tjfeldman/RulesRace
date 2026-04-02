extends Node
class_name PersonalRuleManager

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

#This function checks to see if any players' personal rule will trigger on a roll
func check_roll_condition(roller: Player, roll: Variant):
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
	if player_arr:	for player in player_arr: await _check_personal_rule_trigger(player, roller)
				
func _check_personal_rule_trigger(player: Player, causer: Player):
	var trigger = player.getPersonalRule().get_trigger();
	match trigger:
		PersonalRules.Trigger.SAME_SPACE:
			#Check the rule is triggered by someone other than the causer and the causer and player are in the same space
			if player != causer and player.getBoardPosition() == causer.getBoardPosition():
				print("%s triggered their personal rule"%player);
				
