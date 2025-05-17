extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	return SUCCESS if actor.is_stunned else FAILURE
