extends Node

var characters = {}

func RegisterCharacter(uid, character):
	characters[uid] = character
	
func DeleteCharacter(uid):
	characters.erase(uid)
		
func FindCharacter(uid):
	return characters.get(uid, null)
