import wollok.game.*
import armas.*

object jugador {
	var property vida = 10
	var property position = game.origin()
	var property arma = armaDefault
	
	method image() = "Character.png"
	
	// cantidad puede ser -5 o 5
	method modificarVida(cantidad) {
		vida = vida + cantidad
	}
	
	method moverA(dir) {
		position = dir.siguientePosicion(position) 
	}
}
