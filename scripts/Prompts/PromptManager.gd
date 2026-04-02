extends Node
class_name PromptManager

"""
Prompt Scenes
"""
const CONFIRM_RULE = "res://scenes/Prompts/confirmRuleUsage.tscn";
const OFFICE_CHOICE = "res://scenes/Prompts/officeChoice.tscn";
const RESULTS = "res://scenes/Prompts/results.tscn";
const SELECT_PLAYER = "res://scenes/Prompts/selectPlayerPrompt.tscn";
const ACKNOWLEDGE_PERSONAL_RULE = "res://scenes/Prompts/acknowledgeEvent.tscn";

"""
Dynamic Label Scenes
"""
const PERSONAL_RULE_LABEL = "res://scenes/Prompts/Dynamic/personalRuleEvent.tscn";

"""
GET PROMPT SCENES
"""
static func get_office_choice_prompt(): 
	var prompt = preload(OFFICE_CHOICE)
	return prompt.instantiate();
	
static func get_confirm_rule_prompt(): 
	var prompt = preload(CONFIRM_RULE);
	return prompt.instantiate();
	
static func get_results_prompt(): 
	var prompt = preload(RESULTS)
	return prompt.instantiate();
	
static func get_select_player_prompt(): 
	var prompt = preload(SELECT_PLAYER);
	return prompt.instantiate();
	
static func get_acknowledge_personal_rule_prompt():
	var prompt = preload(ACKNOWLEDGE_PERSONAL_RULE);
	return prompt.instantiate();

"""
GET DYNAMIC LABELS
"""
static func get_personal_rule_label():
	var label = preload(PERSONAL_RULE_LABEL);
	return label.instantiate();
