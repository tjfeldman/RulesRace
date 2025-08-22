extends Control

@onready var group_rule_selector: CenterContainer = $GroupRuleSelector
@onready var whenLabel: Label = $WhenDisplay/Label
@onready var triggerLabel: Label = $TriggerDisplay/Label
@onready var effectLabel: Label = $EffectDisplay/Label

#set to -1 to represent None
var whenRule: GroupRules.When = -1;
var triggerRule: GroupRules.Trigger = -1;
var effectRule: GroupRules.Effect = -1;

func _ready() -> void:
	group_rule_selector.visible = false;
	group_rule_selector.rulesUpdated.connect(_on_rules_updated);
	
func _on_background_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_click"):
		group_rule_selector.visible = !group_rule_selector.visible;
		
func _on_rules_updated(whenRuleBtn: RuleButton, triggerRuleBtn: RuleButton, effectRuleBtn: RuleButton):
	whenLabel.text = whenRuleBtn.description;
	triggerLabel.text = triggerRuleBtn.description;
	effectLabel.text = effectRuleBtn.description;
	
	whenRule = whenRuleBtn.type;
	triggerRule = triggerRuleBtn.type;
	effectRule = effectRuleBtn.type;
