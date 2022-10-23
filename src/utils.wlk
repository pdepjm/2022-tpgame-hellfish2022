import wollok.game.*

object random {
	method natural(from, to) = from.randomUpTo(to).truncate(0)
	method number() = self.natural(1, 10000000)
}

class CenterMessage {
	var message
	method position() = game.center()
	method text() = message
	method textColor() = "000000FF"
}