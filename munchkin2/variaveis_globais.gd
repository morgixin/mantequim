extends Node

const CARD_MONSTER_PATH = "res://Scenes/Cartas/CartaMonstro.tscn"
const CARD_ITEM_PATH = "res://Scenes/Cartas/CartaItem.tscn"
const MALDITION_PATH = "res://Scenes/Cartas/CartaMaldicao.tscn"
const RACE_PATH = "res://Scenes/Cartas/CartaRaca.tscn"
const CLASS_PATH = "res://Scenes/Cartas/CartaClasse.tscn"
const DATA_MONSTER = "res://data/cartas_monstro.json"
const DATA_ITEM = "res://data/cartas_tesouro.json"
const DATA_MALDITION = "res://data/cartas_maldicao.json"
const DATA_CLASS = "res://data/cartas_classe.json"
const DATA_RACA = "res://data/cartas_raca.json"
const BOT_PLAYER_PATH = "res://Scenes/JogadorBot.tscn"
var BOTS_COUNT: int = 2
var MODO_FACIL: bool = true
