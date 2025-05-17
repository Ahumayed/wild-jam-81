extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.move_toward_player()
	return RUNNING
