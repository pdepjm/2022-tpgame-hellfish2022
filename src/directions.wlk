// Directions
object up {
	method nextPosition(pos) = pos.up(1)
	method letter() = "U"
}

object right {
	method nextPosition(pos) = pos.right(1)
	method letter() = "R"
}

object left {
	method nextPosition(pos) = pos.left(1)
	method letter() = "L"
}

object down {
	method nextPosition(pos) = pos.down(1)
	method letter() = "D"
}