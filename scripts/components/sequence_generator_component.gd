extends Node2D
class_name SequenceGenerator
## Letter sequence generator
##
## Generate different types of letter sequences to be used in minigames
## TODO: exclude certain sequences that are known to not work in some keyboards,
## or whitelist good sequences

## TODO: Save in different file
var allowed_words: Array[String] = [ ## List of words to return for typing minigame
	"penguin",
	"computer",
	"keyboard",
	"handshake",
	"cult",
	"gamejam",
	"github",
	"grenade"
]

## All the usable letters in the alphabet, for random sequences
var alphabet: String = "qwertyuiopasdfghjklzxcvbnm"

## Generates a size n random sequence of letters
## Returns string of generated letters
func generate_random(n: int) -> String:
	var output: String = ""
	for _i in range(n):
		var random_id: int = randi() % alphabet.length()
		output += alphabet[random_id]
	return output

## Generates a random word from a whitelisted source
## Returns word as a string of letters
## TODO: Allow selection of different difficulty words
func generate_word() -> String:
	return allowed_words.pick_random()
