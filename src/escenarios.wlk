import wollok.game.*
import personajes.*
import boss.*

object escenario {
	method cargarPersonajes() {
		self.agregarJugador()
		self.agregarBoss()
	}
	
	method agregarJugador() { game.addVisual(jugador) }
	
	method agregarBoss() { game.addVisual(boss) }
	
}
