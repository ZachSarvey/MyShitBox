# MoneyUI.gd
extends CanvasLayer

@onready var money_label: Label = $MarginContainer/MoneyLabel

func _ready():
	if not money_label:
		print("MoneyLabel not found!")
		return

	MoneyManager.money_changed.connect(_on_money_changed)
	_on_money_changed(MoneyManager.get_amount())

func _on_money_changed(new_amount: int):
	if money_label:
		money_label.text = "Money: $" + str(new_amount)
