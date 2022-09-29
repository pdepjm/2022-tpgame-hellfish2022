import wollok.game.*

object pepita {

	method position() = game.center()

	method image() = "pepita.png"

}

object fireball {
  var property position = game.origin()

  method image() = "Fireball.png"
}