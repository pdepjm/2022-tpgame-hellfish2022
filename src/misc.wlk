import wollok.game.*
import utils.*

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
	
	method buffCrash(_) {}
	method bulletCrash(_) {}
}

// HP Bar
class HPBar{
	var hp
	const hpMax = hp
	const position
	
	method refresh(newHp){ hp = newHp}
	
	method position() = position
	
	method hpLevel() = (15 * hp / hpMax).roundUp(0).min(15)
	
	method image() = "hpbar/HPBar" + self.hpLevel().toString() + ".png"
	
	method buffCrash(_) {}
	method bulletCrash(_) {}
	method chocar() {}
}

class ObjetoDelEntorno {
	const objectImages = ["object1.png","object2.png","object3.png","object4.png","object5.png"]
	var property position
	var property image = null
	
	method chocar(){}
	method randomImage() {image = random.lista(objectImages)}
	method bulletCrash(_){}
	method spawn() {
		self.randomImage()
		game.addVisual(self)
		game.onCollideDo(self, {algo => algo.chocar()})
	}	
}

object trapDoor{
	var property position = game.at(20,1)
	var property image = "trapdoor.png"
	method win(){game.removeVisual(self)}
	method bulletCrash(_){}
	method chocar(){}
	method spawn(){
		game.addVisual(self)
		game.onCollideDo(self, {anything => anything.win()})
	}
	
}