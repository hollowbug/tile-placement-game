extends RefCounted
class_name ScoreChange

var increase := 0 :
	set(value):
		increase = value
		total = increase - decrease
var decrease := 0 :
	set(value):
		decrease = value
		total = increase - decrease
var total := 0
