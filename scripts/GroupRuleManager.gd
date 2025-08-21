extends CenterContainer

var whenGroupButtons: Array[BaseButton];
var triggerGroupButtons: Array[BaseButton];
var effectGroupButtons: Array[BaseButton];

var selectedWhenRule : BaseButton;
var selectedTriggerRule : BaseButton;
var selectedEffectRule : BaseButton;

signal rulesUpdated(whenRule: BaseButton, triggerRule: BaseButton, effectRule: BaseButton);

func _ready() -> void:
	whenGroupButtons = $PanelContainer/MarginContainer/GroupRuleSelection/Whens/EveryPlayer.button_group.get_buttons();
	triggerGroupButtons = $PanelContainer/MarginContainer/GroupRuleSelection/Triggers/RollPrison.button_group.get_buttons();
	effectGroupButtons = $PanelContainer/MarginContainer/GroupRuleSelection/Effects/MoveForward.button_group.get_buttons();
	
	call_deferred("random_rule");

func random_rule():
	#select random group rules
	selectedWhenRule = whenGroupButtons.pick_random();
	selectedTriggerRule = triggerGroupButtons.pick_random();
	selectedEffectRule = effectGroupButtons.pick_random();
	
	#toggle selected
	selectedWhenRule.button_pressed = true;
	selectedTriggerRule.button_pressed = true;
	selectedEffectRule.button_pressed = true;
	
	#disable all other buttons
	for toDisable in whenGroupButtons.filter(func(btn): return btn != selectedWhenRule):
		toDisable.disabled = true;
	for toDisable in triggerGroupButtons.filter(func(btn): return btn != selectedTriggerRule):
			toDisable.disabled = true;
	for toDisable in effectGroupButtons.filter(func(btn): return btn != selectedEffectRule):
			toDisable.disabled = true;
			
	rulesUpdated.emit(selectedWhenRule, selectedTriggerRule, selectedEffectRule);
