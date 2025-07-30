extends Area3D

@export var amount: int = 100

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "Player": #Adjust as needed
		MoneyManager.add(amount)
		queue_free()
