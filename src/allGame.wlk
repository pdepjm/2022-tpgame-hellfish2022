import wollok.game.*

// Utils
object random {
	const imagenesEnemys = ["enemy1.png","enemy2.png","enemy3.png","enemy4.png","enemy5.png"]
	const direcciones = [left, right, up, down]
	method natural(from, to) = from.randomUpTo(to).truncate(0)
	method number() = self.natural(1, 10000000)
	method imagenesEnemy() = imagenesEnemys.get(self.natural(0,imagenesEnemys.size())) 
	method direccion() = direcciones.get(self.natural(0,direcciones.size()))
	method lista(list) = list.get(self.natural(0,(list.size()-1))) 
}

class CenterMessage {
	var message
	method position() = game.center()
	method text() = message
	method textColor() = "000000FF"
}

// Directions
object up {
	method cual() = "arriba"
	method nextPosition(pos) = pos.up(1)
}

object right {
	method cual() = "derecha"
	method nextPosition(pos) = pos.right(1)
}

object left {
	method cual() = "izquierda"
	method nextPosition(pos) = pos.left(1)
}

object down {
	method cual() = "abajo"
	method nextPosition(pos) = pos.down(1)	
}

// Game Start / Settings
object engine {
	method startSetting() {
		game.title("HellHead") // HellFish
		game.width(50)
		game.height(25)  
		game.cellSize(50)
		self.keysGeneral()
	}
	method keysSettingPlayer(player) {
		keyboard.a().onPressDo({player.goTo(left)}) 
		keyboard.d().onPressDo({player.goTo(right)}) 
		keyboard.w().onPressDo({player.goTo(up)})
		keyboard.s().onPressDo({player.goTo(down)})
		keyboard.shift().onPressDo({player.attack()})
		keyboard.space().onPressDo({player.jump()})
	}
	method keysSettingPlayerAlter(player) {
		keyboard.left().onPressDo({player.goTo(left)}) 
		keyboard.right().onPressDo({player.goTo(right)}) 
		keyboard.control().onPressDo({player.attack()})
		keyboard.up().onPressDo({player.jump()})
	}
	method keysGeneral(){
		keyboard.r().onPressDo({scenario.restart()})
		keyboard.num(1).onPressDo({
			scenario.dificulty(1)
			scenario.restart()
		})
		keyboard.num(2).onPressDo({
			scenario.dificulty(2)
			scenario.restart()
		})
		keyboard.num(3).onPressDo({
			scenario.dificulty(3)
			scenario.restart()
		})
	}
}


// Scenario
object scenario {
	const playerBasePosition = game.at(1,20)
	const bossBasePosition = game.at(game.center().x() + game.width() / 3, game.center().y() / 3)
	var dificulty = 1
	const enemys = []
	const objetoDelEntorno = []
	
	const xMin = 1
	const xMax = game.width() - game.width() / 10
	const yMin = 1
	const yMax = game.height() - game.height() / 10
	
	method estaEnLava(position) = (position.x().between(13, 50) && position.y().between(6, 9)) or (position.x().between(40, 50) && position.y().between(9, 25))
	method estaAdentro(posicion) = self.limitX(posicion.x()) && self.limitY(posicion.y())
	
	method limitX(positionX) = positionX.between(xMin, xMax)
	method limitY(positionY) = positionY.between(yMin, yMax)
	
	method calculateBossLife() = random.natural(100, 300 * dificulty)
	
	method setGround(){
		game.boardGround("fondo_2.png")
	}
	
	method load(){
		self.setGround()
		
		const player = new Player(hp = 100, position = playerBasePosition, image = "Character.png", direccion = right)
		if (dificulty == 3){
			player.setWeapon(crazyWeapon)
		}else {
			player.setWeapon(new Weapon(damage = 10, buff = 2))
		}
		engine.keysSettingPlayer(player)
		game.addVisual(player)
		player.loadHPBar()
		
		5.times({i=>self.agregarEnemigo(i-1)})
		7.times({i=>self.agregarObjetoDelEntorno(i-1)})
		}
		
	method agregarEnemigo(n){
		enemys.add(new Enemy(hp=random.natural(50,200), position=self.randomPosition(), direccion = left, id = random.number().toString() )) 
		enemys.get(n).spawn()
	}
	
	method agregarObjetoDelEntorno(n){
		objetoDelEntorno.add(new ObjetoDelEntorno(position=self.positionNotInLava()))
		objetoDelEntorno.get(n).spawn()
	}
	
	method end(){
		game.schedule(1000,
			{
				game.clear()
				game.addVisual(new CenterMessage(message = "GAME END"))
			}
		)
	}
	
	method restart(){
		game.clear()
		self.load()
	}
	
	method removeEnemy(enemy) = enemys.remove(enemy) 
	method ningunEnemigo() = enemys.isEmpty()
	
	method randomPosition() = game.at(random.natural(1,49),random.natural(1,24))
	
	method positionNotInLava(){
		const newPosition = self.randomPosition()
		 return (if(self.estaEnLava(newPosition))self.positionNotInLava() else newPosition)
		}
	
	method dificulty(lvl){
		dificulty = lvl
	}
}

object scenarioPVP {
	const playerBasePosition = game.at(game.center().x() - game.width() / 3, game.center().y() / 3)
	const alterPlayerBasePosition = game.at(game.center().x() + game.width() / 3, game.center().y() / 3)
	
	const xMin = game.width() / 10
	const xMax = game.width() - game.width() / 10
	const yMin = game.height() / 10
	const yMax = game.height() - game.height() / 10

	method estaAdentro(posicion) = self.limitX(posicion.x()) && self.limitY(posicion.y())
	
	method limitX(positionX) = positionX.between(xMin, xMax)
	method limitY(positionY) = positionY.between(yMin, yMax)
	
	method setGround(){
		game.boardGround("fondo1.png")
	}
	
	method load(){
		self.setGround()
		
		const player = new Player(hp = 100, position = playerBasePosition, image = "Character.png",direccion=null)
		player.setWeapon(new Weapon(damage = 10, buff = 2))
		engine.keysSettingPlayer(player)
		game.addVisual(player)
		
		const playerAlter = new Player(hp = 100, position = alterPlayerBasePosition, image = "Character_Alter.png",direccion=null)
		playerAlter.setWeapon(new Weapon(damage = 10, buff = 2))
		engine.keysSettingPlayerAlter(playerAlter)
		game.addVisual(playerAlter)
	}
	
	method end(){
		game.schedule(1000,
			{
				game.clear()
				game.addVisual(new CenterMessage(message = "GAME END"))
			}
		)
	}
}

// Characters
class Character {
	var hp
	var weapon = null
	var property direccion 
	var property position
	var property image = null
	var property hpbar = null
	
	
	
	method image(imagen) { image = imagen}
	
	//Para mostrar la vida por consola
	method hp() = hp
	
	method setWeapon(newWeapon) {weapon = newWeapon}
	
	method die()
	
	method alive() = hp > 0
	
	
	method bulletCrash(damage) { self.removeLife(damage) }
	
	method removeLife(mount) {
		hp = (hp - mount).max(0)
		hpbar.removeLife(mount)
		if (self.alive().negate()) self.die()
	}
	
	method win()
	
	method attack() =if(direccion.cual()=="izquierda") weapon.fire(position.left(1), direccion) else weapon.fire(position.right(1), direccion)
	
	method loadHPBar(){
		hpbar = new HPBar(hp = hp, position = self.hpBarPosition(), characterName = "TEST")
		game.addVisual(hpbar)
	}
	
	method movimiento(dir){if( scenario.estaAdentro(dir.nextPosition(position)))position = dir.nextPosition(position)}	
	
	method chocar(){
		if(direccion.cual()=="izquierda") position=position.left(-2)
		if(direccion.cual()=="derecha") position=position.right(-2)
		if(direccion.cual()=="arriba") position=position.up(-2)
		if(direccion.cual()=="abajo") position=position.down(-2)
	}
	
	method hpBarPosition() = game.at(position.x(), game.height() - game.height() / 10)
}

class Boss inherits Character {
	const dificulty // Dificulty 1 2 3
	
	const bosses = ["Boss_1.png", "Boss_2.png"]
	
	method randomImage() {
		image = bosses.get(random.natural(0, bosses.size() - 1))
	}
	
	method start(){
		game.onTick(750, "autoAttack", {self.autoAttack()})
		
	}
	
	override method attack() = weapon.fire(position.left(1), left)
	
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

class Enemy inherits Character {
	
	const dificulty=2
	const id
	const imagenesEnemys = ["enemy1.png","enemy2.png","enemy3.png","enemy4.png","enemy5.png"]
	
	
	method randomImage(){image=random.lista(imagenesEnemys)}
	
	override method die(){
		game.removeTickEvent("autoAttack"+id)
		game.say(self, "D:")
		game.schedule(1000, {game.removeVisual(self)})
		scenario.removeEnemy(self)
		if(scenario.ningunEnemigo()) door.spawn()
		}
	method start(){
		game.onTick(750, "autoAttack"+id, {self.attack()})
		game.onTick(500, "movimiento"+id, {self.move()})
		
	}
	
	override method attack() =if(direccion.cual()=="izquierda") weapon.fire(position.left(1), direccion) else weapon.fire(position.right(1), direccion)
	
	method move(){
		const dir = random.direccion()
		self.movimiento(dir)
		direccion = dir	
	}
	
	method spawn(){
		self.setWeapon(new Weapon(damage = 10, buff = 2))
		self.loadHPBar()
		self.randomImage()
		self.start()
		game.addVisual(self)
	}
	override method win(){}
}

class Player inherits Character {
	override method die(){
		game.say(self, "Zzzzzz GG NO TEAM")
		//game.schedule(1500, {scenario.end()})
	}
	
		
	method goTo(dir) {
		self.movimiento(dir)
		if( scenario.estaAdentro(dir.nextPosition(position)))position = dir.nextPosition(position)		
		if(scenario.estaEnLava(dir.nextPosition(position)))self.die()
		if(dir.cual()=="derecha"){self.image("Character.png")
			direccion = dir
		}else{if(dir.cual()=="izquierda"){self.image("Character_Alter.png") 
			direccion =dir
		}}
	}
	
	method jump(){
        if ( scenario.estaAdentro(right.nextPosition(position.right(1))) ){
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
		game.schedule(1000, {scenario.end()})
	}
}

// Misc
// Weapon and Bullet
class Weapon {
	const damage
	const buff
	const bulletImage = "Fireball.png"
	
	method calculateDamage() = damage * buff
	// method image() = bulletImage
	
	method fire(startPosition, orientation){
		const bullet = new Bullet(
			position = startPosition,
			damage = self.calculateDamage(),
			image = bulletImage,
			orientation = orientation,
			id = random.number()
		)
		bullet.startPath()
	}
}

object crazyWeapon inherits Weapon(damage = 20, buff = 1){
	override method fire(startPosition, _){
		const probability = random.natural(0, 100)
		var orientation = null
		if (probability > 75){
			orientation = up
		} else if (probability > 50){
			orientation = left
		} else if (probability > 25){
			orientation = right
		} else {
			orientation = down
		} 
		const bullet = new Bullet(
			position = startPosition,
			damage = self.calculateDamage(),
			image = bulletImage,
			orientation = orientation,
			id = random.number()
		)
		bullet.startPath()
	}
}

class Bullet {
	const damage
	const orientation
	const id
	
	const image
	var property position
	
	method image() = image
	method position() = position
	
	method startPath(){
		game.addVisual(self)
		game.onCollideDo(self, { something =>
			something.bulletCrash(damage)
			self.destroy()
		})
		game.onTick(20, self.unicID(), {self.move()})
	}
	
	method unicID() = "bullet" + id.toString()
	
	method move() {
		if (self.onLimit()){
			position = orientation.nextPosition(position)
		} else {
			self.destroy()
		}
	}
	
	method onLimit() = scenario.estaAdentro(orientation.nextPosition(position))
	
	method destroy() {
		game.removeTickEvent(self.unicID())
		game.removeVisual(self)
	}
	
	method bulletCrash(_) {
		self.destroy()
	}
	method dontMove() {self.bulletCrash(0)}
	method win() {}
	method chocar() {}
}

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
	var characterName
	const position
	method removeLife(mount){
		hp = (hp - mount).max(0)
	}
	method text() = characterName + " - " +  hp.toString()
	method textColor() = "FFFFFFFF"
	method position() = position
	method bulletCrash(_){}
}

class ObjetoDelEntorno {
	const objectImages = ["object1.png","object2.png","object3.png","object4.png","object5.png"]
	var property position
	var property image = null
	
	method randomImage() {image = random.lista(objectImages)}
	method bulletCrash(_){}
	method spawn() {
		self.randomImage()
		game.addVisual(self)
		game.onCollideDo(self, {algo => algo.chocar() game.say(algo, "puto")})
	}
	
		
}
