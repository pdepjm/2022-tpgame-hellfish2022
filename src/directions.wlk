// Directions
object up {
	method nextPosition(pos) = pos.up(1)
	method letter() = "U"
	method invert() = down
}

object right {
	method nextPosition(pos) = pos.right(1)
	method letter() = "R"
	method invert() = left
}

object left {
	method nextPosition(pos) = pos.left(1)
	method letter() = "L"
	method invert() = right
}

object down {
	method nextPosition(pos) = pos.down(1)
	method letter() = "D"
	method invert() = up
}