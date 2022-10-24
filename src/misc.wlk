import wollok.game.*

// Door - WIN
object door{
	var property position
	
	method image() = "CaveDoor.png"
	
	method position() = position
	
	method spawn() {
		position = game.at(game.center().x() + game.width() / 3, game.center().y() / 3)
		game.addVisual(self)
		game.onCollideDo(self, {anything => anything.win()})
	}
}

// HP Bar
class HPBar{
	var hp
	var hpMax = 0
	const position
	
	method initialize(){
		hpMax = hp
	}
	
	method removeLife(mount){
		hp = (hp - mount).max(0)
	}
	
	method position() = position
	
	method hpLevel() = (15 * hp / hpMax).roundUp(0).min(15)
	
	method image() = "hpbar/HPBar" + self.hpLevel().toString() + ".png"
	
	method buffCrash(_) {}
	method bulletCrash(_) {}
}