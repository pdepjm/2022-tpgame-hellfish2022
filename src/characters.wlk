import weapons.*
import misc.*
import wollok.game.*
import utils.*
import directions.*
import screen.*

// Characters
class Character {
	var hp
	var weapon = noWeapon
	var property position
	var property image = null
	var property hpbar = null
	var property orientation = left
	
	method image() = image + orientation.letter() + ".png"
	
	//Para mostrar la vida por consola
	method hp() = hp
	
	method setWeapon(newWeapon) {weapon = newWeapon}
	method weapon() = weapon
	
	method die()
	
	method alive() = hp > 0
	
	method attack()
	
	method bulletCrash(damage) { self.removeLife(damage) }
	
	method buffCrash(buff) { buff.apply(self) }
	
	method removeLife(mount) {
		hp = (hp - mount).max(0)
		hpbar.removeLife(mount)
		if (self.alive().negate()){
			self.die()
		} else {
			// game.say(self, hp.toString())
		}
	}
	
	method addLife(mount) { hp += mount	}
	
	method win()
	
	method loadHPBar(){
		hpbar = new HPBar(hp = hp, position = self.hpBarPosition())
		game.addVisual(hpbar)
	}
	
	method hpBarPosition() = game.at(position.x(), game.height() - game.height() / 10)
}

class Boss inherits Character {
	const dificulty // Dificulty 1 2 3
	
	override method image() = "bosses/" + image + ".png"
	
	method start(){
		game.onTick(200, "autoAttack", {self.autoAttack()})
	}
	
	override method attack() {
		weapon.fire(position.left(1), left)
	}
	
	method autoAttack(){
		const probability = random.natural(0, 100)
		if (probability > 75.min(100 / dificulty)){
			self.attack()
		} 
	}
	
	// Life
	override method die(){
		game.removeTickEvent("autoAttack")
		game.say(self, "Volvere mas fuerte...")
		game.schedule(5000, {
			game.removeVisual(self)
			door.spawn()
		})
	}
	
	override method win() {}
}

class Player inherits Character {
	override method image() = "characters/" + super()
		
	override method die(){
		game.say(self, "Zzzzzz GG NO TEAM")
		game.schedule(2000, {playScreen.levelCharacteristics().end()})
	}
	
	
	override method attack() {
		weapon.fire(orientation.nextPosition(position), orientation)
	}
	

	method goTo(dir) {
		if( playScreen.estaAdentro(dir.nextPosition(position)) ){
			orientation = dir
			position = dir.nextPosition(position)
		}
	}
	
	method jump(){
        if ( playScreen.estaAdentro(right.nextPosition(position.right(1))) ){
            position = position.up(3).right(1)
            game.schedule(300, {position = position.down(3).right(1)})
        } else {
            position = position.up(3)
            game.schedule(300, {position = position.down(3)})
        }
    }
	
	override method win() {
		game.removeVisual(self)
		game.say(door, "GANE! SOY EL MEJOR!")
		game.schedule(1000, {playScreen.levelCharacteristics().end()})
	}
}
