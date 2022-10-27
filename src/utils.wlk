import wollok.game.*
import directions.*

object random {
	const direcciones = [left, right, up, down]
	method natural(from, to) = from.randomUpTo(to).truncate(0)
	method number() = self.natural(1, 10000000)
	method direccion() = direcciones.get(self.natural(0,direcciones.size()))
	method lista(list) = list.get(self.natural(0,(list.size()-1))) 
}

object mod {
	method calculate(base, number) = number - (base * number.div(base))
}

class CenterMessage {
	var message
	method position() = game.center()
	method text() = message
	method textColor() = "000000FF"
}

object void {
	method image() = "Character.png"
}