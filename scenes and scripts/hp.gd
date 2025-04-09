# ################
# hp - health point (eletero pont) -> egy 0 es 100 koze clamp-elt erteket kezel
# a player es az enemy-k altal is hasznalva
# ################
extends Node2D

# hp setter 
var hp : int = 100:
	set = set_hp


# clamp 0 es 100 koze - biztositja, hogy a ket ertek kozott marad
func set_hp(new_hp: int):
	hp = clamp(new_hp, 0, 100)
