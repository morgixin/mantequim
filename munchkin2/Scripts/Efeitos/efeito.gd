class_name Efeito
extends Node

var acao = -1
var acaoParametro = -1
var target = -1
var alvoDoEfeito: int = -1 # Indefinido: -1; Monstro: 0; Jogador: 1  
var alvoJogadorDoEfeito: Jogador = null
var alvoMonstroDoEfeito: CartaMonstro = null
var textoResultado: String = "O jogador não sofreu efeito"

static func create(tipoEfeito: int) -> Efeito:
	var novoEfeito: Efeito
	var efeitoDict = {
		1: EfeitoMudaForca,
		2: EfeitoModificarNivel,
		3: EfeitoRemoveItem,
		4: EfeitoRemoveClasse,
		5: EfeitoRemoveCartas,
		6: EfeitoMudaRaca,
		7: EfeitoFuga,
		8: EfeitoPassaro
	}

	novoEfeito = efeitoDict[tipoEfeito].new() if efeitoDict.has(tipoEfeito) else Efeito.new()
	novoEfeito.acao = tipoEfeito

	return novoEfeito

func processarEfeito(alvoDoEfeito: int, objetoDoEfeito, acao_parametro: int, target: int = -1) -> void:
	prepararEfeito(alvoDoEfeito, objetoDoEfeito, acao_parametro, target)
	_aplicarEfeito()
	_finalizarEfeito()

func prepararEfeito(alvoDoEfeito: int, objetoDoEfeito, acao_parametro: int, target: int) -> void:
	self.alvoDoEfeito = alvoDoEfeito
	self.acaoParametro = acao_parametro
	self.target = target
	if (alvoDoEfeito == 0):
		self.alvoMonstroDoEfeito = objetoDoEfeito
	if (alvoDoEfeito == 1):
		self.alvoJogadorDoEfeito = objetoDoEfeito

func _aplicarEfeito() -> void:
	pass

func _finalizarEfeito() -> void:
	pass

func obterTextoResultado() -> String:
	return textoResultado
