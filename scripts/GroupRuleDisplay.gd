extends Control

@onready var group_rules: CenterContainer = $GroupRules
@onready var whenLabel: Label = $WhenDisplay/Label
@onready var triggerLabel: Label = $TriggerDisplay/Label
@onready var effectLabel: Label = $EffectDisplay/Label

func _ready() -> void:
	group_rules.visible = false;
	group_rules.rulesUpdated.connect(_on_rules_updated);
	
func _on_background_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_click"):
		group_rules.visible = !group_rules.visible;
		
func _on_rules_updated(whenRule: BaseButton, triggerRule: BaseButton, effectRule: BaseButton):
	whenLabel.text = whenRule.text;
	triggerLabel.text = triggerRule.text;
	effectLabel.text = effectRule.text;
