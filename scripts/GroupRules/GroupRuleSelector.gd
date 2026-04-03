extends CenterContainer

@export var whenGroup: ButtonGroup;
@export var triggerGroup: ButtonGroup;
@export var effectGroup: ButtonGroup;

@onready var same_rule_warning_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SameRuleWarningLabel
@onready var incomplete_rule_warning_label: Label = $PanelContainer/MarginContainer/VBoxContainer/IncompleteRuleWarningLabel
@onready var confirm_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ConfirmBtn
func isEditing(): return confirm_btn.visible;

var _currentWhenRule : WhenButton;
var _currentTriggerRule : TriggerButton;
var _currentEffectRule : EffectButton;

signal rules_updated(whenRule: RuleButton, triggerRule: RuleButton, effectRule: RuleButton);

func _ready() -> void:
	call_deferred("_set_new_rule");
	_set_for_display();

func set_for_editing():
	self.visible = true;
	for btn in whenGroup.get_buttons():
		btn.enable();
	for btn in triggerGroup.get_buttons():
		btn.enable();
	for btn in effectGroup.get_buttons():
		btn.enable();
	confirm_btn.visible = true;
	get_tree().current_scene.toggle_hud();
	
func _set_for_display():
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
	
	if _currentWhenRule and _currentTriggerRule and _currentEffectRule:
		rules_updated.emit(_currentWhenRule, _currentTriggerRule, _currentEffectRule);

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
		var random_rule_arr = ValidRules.VALID_RULES.pick_random();	
		selectedWhen = whenGroup.get_buttons().filter(func(btn): if btn.type == random_rule_arr[0]: return btn)[0];
		selectedTrigger = triggerGroup.get_buttons().filter(func(btn):  if btn.type == random_rule_arr[1]: return btn)[0];
		selectedEffect = effectGroup.get_buttons().filter(func(btn):  if btn.type == random_rule_arr[2]: return btn)[0];
		
		sameWhen = selectedWhen == _currentWhenRule;
		sameTrigger = selectedTrigger == _currentTriggerRule;
		sameEffect = selectedEffect == _currentEffectRule;
	#END WHEN
	
	_currentWhenRule = selectedWhen;
	_currentTriggerRule = selectedTrigger;
	_currentEffectRule = selectedEffect;
	
	#toggle selected
	_currentWhenRule.button_pressed = true;
	_currentTriggerRule.button_pressed = true;
	_currentEffectRule.button_pressed = true;
	
	_set_for_display();

func _on_confirm_btn_pressed() -> void:
	#verify that the selected btns are not the same ones already selected
	var selectedWhen = whenGroup.get_pressed_button();
	var selectedTrigger = triggerGroup.get_pressed_button();
	var selectedEffect = effectGroup.get_pressed_button();
	
	var sameWhen = selectedWhen == _currentWhenRule;
	var sameTrigger = selectedTrigger == _currentTriggerRule;
	var sameEffect = selectedEffect == _currentEffectRule;
	
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
		_currentWhenRule = selectedWhen;
		_currentTriggerRule = selectedTrigger;
		_currentEffectRule = selectedEffect;
		
		self.visible = false;
		_set_for_display();
		
#TESTING ONLY METHOD
func _set_new_rule():
	var selectedWhen = GroupRules.When.PRISON;
	var selectedTrigger = GroupRules.Trigger.DISCARD_TICKET;
	var selectedEffect = GroupRules.Effect.GAIN_TICKET;
	
	#Grab the buttons
	_currentWhenRule = whenGroup.get_buttons().filter(func(btn): if btn.type == selectedWhen: return btn)[0];
	_currentTriggerRule = triggerGroup.get_buttons().filter(func(btn):  if btn.type == selectedTrigger: return btn)[0];
	_currentEffectRule = effectGroup.get_buttons().filter(func(btn):  if btn.type == selectedEffect: return btn)[0];
	
	#press the buttons
	_currentWhenRule.button_pressed = true;
	_currentTriggerRule.button_pressed = true;
	_currentEffectRule.button_pressed = true;
	
	_set_for_display();
