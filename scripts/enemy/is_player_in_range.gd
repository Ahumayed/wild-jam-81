extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	
	if actor.can_see_player():
		return SUCCESS
	else:
		return FAILURE
