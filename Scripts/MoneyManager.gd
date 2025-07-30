# MoneyManager.gd
extends Node

var money: int = 0

signal money_changed(new_amount: int)

func add(amount: int):
	money += amount
	emit_signal("money_changed", money)

func subtract(amount: int):
	money = max(money - amount, 0)
	emit_signal("money_changed", money)

func get_amount() -> int:
	return money
