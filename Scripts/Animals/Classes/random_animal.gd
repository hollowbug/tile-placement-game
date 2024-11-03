extends Animal
class_name RandomAnimal

var permanent := false
var category := -1
var terrain := -1

func _init():
	sprite = preload("res://Sprites/random_animal.png")
