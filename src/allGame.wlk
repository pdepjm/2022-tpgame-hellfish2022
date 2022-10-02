import wollok.game.*

object up {
	method nextPosition(pos) = pos.up(1) 	
}

object right {
	method nextPosition(pos) = pos.right(1) 	

}
object left {
	method nextPosition(pos) = pos.left(1) 	
}

object down {
	method nextPosition(pos) = pos.down(1) 	
}

object engine {
	method startSetting() {
		game.title("HellHead") // HellFish
		game.width(50)
		game.height(25)  
		game.cellSize(30) 
	}
	method keysSetting() {
		keyboard.w().onPressDo({player.goTo(up)})
		keyboard.a().onPressDo({player.goTo(left)}) 
		keyboard.s().onPressDo({player.goTo(down)}) 
		keyboard.d().onPressDo({player.goTo(right)}) 
		keyboard.space().onPressDo({player.attack()})
	}
}


object random {
	method natural(from, to) = from.randomUpTo(to).truncate(0)
}

object scenario {
	// const image = ""
	const playerBasePosition = game.at(game.center().x() - game.width() / 3, game.center().y())
	const bossBasePosition = game.at(game.center().x() + game.width() / 3, game.center().y())
	const hpBoss = random.natural(0, 250)
	
	method load(){
		player.startAt(playerBasePosition)
		player.setWeapon(new Weapon(damage = 10, buff = 2))
		game.addVisual(player)
		
		const boss = new Boss(hp = hpBoss, position = bossBasePosition)
		boss.randomBoss()
		boss.startAt(bossBasePosition)
		game.addVisual(boss)
	}
}



class Boss {
	var hp
	var property position
	const bosses = ["Boss_1.png", "Boss_2.png"]
	var image = null
	
	
	// Image Boss
	method image() = image
	method randomBoss() {
		image = bosses.get(random.natural(0, bosses.size() - 1))
	}
	
	// Life
	method removeLife(mount) {
		hp = (hp - mount).max(0)
		if (self.alive().negate()) {
			self.dead()
		} else {
			// self.animateHit()
		}
		game.say(self, hp.toString())
	}
	
	method alive() = hp > 0
	
	method dead(){
		game.say(self, "Volvere mas fuerte...")
		game.schedule(5000, {game.removeVisual(self)})
	}
	
	method animateHit(){
		game.removeVisual(self)
		game.schedule(250, {game.addVisual(self)})
		game.schedule(500, {game.removeVisual(self)})
		game.schedule(750, {game.addVisual(self)})
		game.schedule(1000, {game.removeVisual(self)})
		game.schedule(1250, {game.addVisual(self)})
	}
	
	// Position
	method startAt(basePosition) {
		position = basePosition
	}
	
	// Polimorfismo
	method bulletCrash(damage){
		self.removeLife(damage)
	}
}


object player {
	var hp = 100
	var weapon = null
	
	var property position
	
	// Image Character
	method image() = "Character.png"
	
	// Life
	method addLife(mount) {hp = hp + mount}
	method removeLife(mount) {hp = (hp - mount).max(0)}
	
	method alive() = hp > 0
	
	// Weapon
	method setWeapon(newWeapon) {weapon = newWeapon}
	
	method attack() {
		const bullet = new Bullet(position = position.right(1), weapon = weapon)
		game.addVisual(bullet)
		bullet.move()
	}
	
	// Position
	method startAt(basePosition) {
		position = basePosition
	}
	
	method goTo(dir) {
		position = dir.nextPosition(position)
	}
	
	// Polimorfismo
	method bulletCrash(damage){
		self.removeLife(damage)
	}
}

class Weapon {
	const damage
	const buff
	const image = "Fireball.png"
	
	method damage() = damage * buff
	method image() = image
}

class Bullet {
	var position
	const weapon
	var hit = false
	
	method image() = weapon.image()
	method position() = position
	
	// Issue 1 - La bala no desaparece en onCollide
	method move() {
		game.onCollideDo(self, { something =>
			something.bulletCrash(weapon.damage())
			game.removeVisual(self)
			hit = true
			game.say(player, hit.toString())
		})
		// game.onCollideDo(self, { _ => game.removeVisual(self) })
		if (hit.negate()){
			game.onTick(20, "bullet", {self.goToRight()})
		}
	}
	
	method goToRight(){
		position = position.right(1)
		if ( position.x() > game.width() ){
			game.removeTickEvent("bullet")
			game.removeVisual(self)
		}
	}
	
	method bulletCrash(damage) {}
}