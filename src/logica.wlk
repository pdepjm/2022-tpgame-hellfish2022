import wollok.game.*
import personajes.*
import direcciones.*

object engine {
	
	method configuracionInicial() {
		game.title("HellHead") // HellFish
		game.width(50)
		game.height(25)  
		game.cellSize(30) 
	}
	
	
	method configurarAcciones() {
		game.onCollideDo(jugador, {elemento => elemento.levantar(elemento)})
	}
	
	method configurarTeclas() {
		keyboard.w().onPressDo({jugador.moverA(arriba)})
		keyboard.a().onPressDo({jugador.moverA(izquierda)}) 
		keyboard.s().onPressDo({jugador.moverA(abajo)}) 
		keyboard.d().onPressDo({jugador.moverA(derecha)}) 
		
		 
	}
	
}
