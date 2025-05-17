extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	
	if actor.is_touching_player():
		return SUCCESS
	
	else:
		return FAILURE
