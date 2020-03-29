import sys
from os.path import abspath, dirname, join

from PySide2.QtCore import QObject, Slot
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine

from style_rc import *

import logging
logging.basicConfig(level=logging.INFO)


import sqlite3

def _query(self, query, *args):
		con = None
		data = None
		
		try:
			con = sqlite3.connect( DATABASE )
			cur = con.cursor()
			cur.execute(query, tuple(args))
			data = cur.fetchall()
			if not data:
				con.commit()
		except sqlite3.Error as e:
			self.log.error("Database error: %s" % e)
		except Exception as e:
			self.log.error("Exception in _query: %s" % e)
		finally:
			if con:
				con.close()
		return data


class App(QObject):

	def __init__(self):
		super(App, self).__init__()
		self.events = [{"id": 0, "name": "bonjour","date": "21 Sept", "isOver": True,"room": True, "stuff": True, "stewart": True, "guests": True, "managers": [{"name": "Jean Guy"}, {"name": "Madeleine"}]},
		{"id": 1, "name": "au revoir","date": "27 Oct", "isOver": False,"room": False, "stuff": False,"stewart": True, "guests": True,"managers": [{"name": "Jean Guy"}, {"name": "Madeleine"}, {"name": "Zippy"}]}]
		currentEvent = 0

			#DB
		self.db = sqlite3.connect('cinemanager.db')
		self.initDB()

		self.user = False

	def __del__(self):
		self.db.close()



	def initDB(self):
		logging.info('[DB] initialization')
		cursor = self.db.cursor()
			#Create tables	#TODO: store password hashes instead of clear text
		cursor.execute("""
			CREATE TABLE IF NOT EXISTS users(
				id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
				login TEXT UNIQUE,
				password TEXT,
				role INTEGER DEFAULT 1,
				daysoff TEXT DEFAULT ""
			)""")
		cursor.execute("""
			CREATE TABLE IF NOT EXISTS roles(
				id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
				role TEXT UNIQUE
			)""")
		cursor.execute("""
			CREATE TABLE IF NOT EXISTS events(
				id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
				isMovie BOOLEAN DEFAULT 0,
				name TEXT DEFAULT "",
				realisator TEXT DEFAULT "<unknown>",
				category TEXT DEFAULT "<unknown>",
				date DATE,
				isOver BOOLEAN,
				room BOOLEAN,
				stuff BOOLEAN,
				stewarts BOOLEAN,
				guests BOOLEAN,
				managersIDs TEXT DEFAULT "",
				price REAL DEFAULT 0.0,
				places INTEGER DEFAULT 0,
				sold INTEGER DEFAULT 0,
				total REAL DEFAULT 0
			)""")
		self.db.commit()

			#Add roles
		roles = [["Mairie"], ["Membre d'équipe"], ["Administrateur"]]
		for r in roles:
			cursor.execute('INSERT OR IGNORE INTO roles(role) VALUES (?)', r)

			#Add default root user 		#TODO : change password option
		cursor.execute('INSERT OR IGNORE INTO users(login, password, role) VALUES (?, ?, ?)', ["root", "toor", 3])

		
		self.db.commit()





		######### Links with the view (qml)

	@Slot(str, str, result=bool)
	def login(self, login, passwd):
		logging.info(f'[LOGIN] from : {login}')


			# if login & pw ok => send user's role
		cursor = self.db.cursor()
		cursor.execute("""
			SELECT users.id, users.login, users.role, roles.role
			FROM users
			LEFT JOIN roles ON roles.id = users.role
			WHERE login = ? AND password = ?""", [login, passwd])
		result = cursor.fetchone()

		if (result):
			logging.info("[LOGIN] success")
			self.user = {
				"id": result[0],
				"name": result[1],
				"roleID": result[2],
				"role": result[3]
			}
			return True
		else:
			logging.info("[LOGIN] failure")
			return False


	@Slot(str, str, result=bool)
	def signin(self, login, passwd):
		logging.info(f'[SIGNIN] from : {login}')

		cursor = self.db.cursor()
		
		try:
			cursor.execute("""
				INSERT INTO users (login, password)
				VALUES(?, ?)""", [login, passwd])

		except sqlite3.IntegrityError:
			logging.info("[SIGNIN] failure")
			return False

		self.db.commit()
		logging.info("[SIGNIN] success")
		return True


	#get all the events			
	@Slot(result="QVariantList")
	def getEvents(self):
		logging.info(f'[EVENTS] Get events')

		cursor = self.db.cursor()
		res = cursor.execute("""SELECT * FROM events""")

		events = []
		for e in res:
			events.append({
				"id": e[0], "isMovie": e[1], "name": e[2],
				"realisator": e[3], "category": e[4],
				"date": e[5], "isOver": e[6], "room": e[7],
				"stuff": e[8], "stewarts": e[9],"guests": e[10], 
				"managers": [int(m) for m in e[11].split(',') if m],
				"price": float(e[12]), "places": int(e[13]),
				"sold": int(e[14]), "total": float(e[15])
			})

		return events

		#get users list, eg. for the admin
	@Slot(result="QVariantList")
	def getUsers(self):
		logging.info(f'[EVENTS] Get users')

		cursor = self.db.cursor()
		res = cursor.execute("""
			SELECT users.id, users.login, users.role, roles.role
			FROM users
			LEFT JOIN roles ON roles.id = users.role""")

		users = []
		for u in res:
			users.append({
				"id": u[0], "name": u[1], "roleID": u[2], "role": u[3]
			})

		return users


		#get a user's name from his id
	@Slot(int, result=str)
	def getUserName(self, id):
		logging.info(f'[EVENTS] Get user')

		cursor = self.db.cursor()
		cursor.execute("""SELECT login FROM users WHERE id = ?""", [id])
		r = cursor.fetchone()[0]

		return r

		#save new event / update existing one's infos
	@Slot("QJSValue")
	def saveEvent(self, newevent):
		newevent = newevent.toVariant()

		print(newevent)
		
		id = newevent.pop('id')
		managers = [int(m) for m in newevent.pop('managers')]

			#convert dict to list for sqlite
		event_formatted = [v for k, v in newevent.items()]
		
			#check if the event is "terminated"
		if (newevent['guests'] and newevent['room'] and newevent['stewarts'] and newevent['stuff']):
			event_formatted.append(True)
		else:
			event_formatted.append(False)

			#gen a csv from managers's IDs to store them in TEXT
		event_formatted.append(str(managers)[1:-1])

			# calcule total des ventes
		event_formatted.append( float(newevent['price']) * float(newevent['sold']) ) #TODO: secure input

		if (id<= 0): #if its a ne event
			logging.info(f'[EVENTS] Save new event')

				# /!\ the parameters order is in alphabetical order (cf dict to list)
			cursor = self.db.cursor()
			cursor.execute("""
				INSERT INTO events (category, date,
				guests, name, places, price, realisator,
				room, sold, stewarts, stuff, isOver, managersIDs, total)
				VALUES(?, ?, ?, ?, ?, ?, ?, ?,  ?, ?, ?, ?, ?, ?)""", event_formatted)
			self.db.commit()

		else:
			logging.info(f'[EVENTS] update event {int(id)}')
			event_formatted.append(int(id)) #for the WHERE close

			cursor = self.db.cursor()
			cursor.execute("""
				UPDATE events SET category = ?,
				date = ?, guests = ?, name = ?,
				places = ?, price = ?, realisator = ?,
				room = ?, sold = ?, stewarts = ?, stuff = ?,
				isOver = ?, managersIDs = ?, total = ?
				WHERE id = ?""", event_formatted )
			self.db.commit()


		#get the connected user's infos
	@Slot(result="QVariant")
	def getUserInfo(self):
		logging.info(f'[APP] Get user infos')
		return self.user

		#send the editing event datas
	@Slot(result="QVariant")
	def getCurrentEvent(self):
		logging.info(f'[EVENTS] Get current event')
		cursor = self.db.cursor()
		cursor.execute("""SELECT * FROM events WHERE id = ?""", [self.currentEvent])

		e = cursor.fetchone()
		event = {
			"id": e[0], "isMovie": e[1], "name": e[2],
			"realisator": e[3], "category": e[4],
			"date": e[5], "isOver": e[6], "room": e[7],
			"stuff": e[8], "stewart": e[9],
			"guests": e[10], "managers": [int(m) for m in e[11].split(',') if m],
			"price": float(e[12]), "places": int(e[13]),
			"sold": int(e[14]), "total": float(e[15])
		}

		return event

		#we store the id of the editing product to get it later
	@Slot(int, result="QVariant")
	def selectEvent(self, id):
		logging.info(f'[EVENTS] Set current event ({id})')
		self.currentEvent = id

	
		#for "mycalendar" view : update the user's days off
		# we save thoses days by their timestamp
	@Slot("QJSValue")
	def saveDaysOff(self, daysOff):
		logging.info(f'[CALENDAR] update daysoff (user {self.user["id"]})')

		daysOff = daysOff.toVariant()

		daysOff_formatted = [str(daysOff)[1:-1], self.user["id"]]

		cursor = self.db.cursor()
		cursor.execute("""
			UPDATE users SET daysoff = ?
			WHERE id = ?""", daysOff_formatted )
		self.db.commit()

		#returns an array with all the daysoff of an user (given by its id)
	@Slot(int, result="QVariantList")
	def getDaysOff(self, user):
		logging.info(f'[CALENDAR] get daysoff of user : {user})')
		if (user is -1):
			user = self.user["id"]

		cursor = self.db.cursor()
		cursor.execute("""
			SELECT daysoff FROM users
			WHERE id = ?""", [user] )
		
		d = cursor.fetchone()[0]

		# d = "timestapm.0, timestapm1.0, timestapm2.0"

		return [int( float(i) ) for i in d.split(',') if i]


		#returns an array of the differents roles (eg. Administrator, ...)
	@Slot(result="QVariantList")
	def getRoles(self):
		logging.info(f'[ROLES] get roles')
		
		cursor = self.db.cursor()
		r = cursor.execute("""
			SELECT * FROM roles""")

		roles = []
		for l in r:
			roles.append({"id": l[0], "role": l[1]})

		return roles

	@Slot("QJSValue")
	def updateRole(self, data):
		data = data.toVariant()

		userId = int(data[0])
		roleId = int(data[1])


		logging.info(f'[ROLES] update role of user {userId} to {roleId}')
		
		cursor = self.db.cursor()
		cursor.execute("""
			UPDATE users SET role = ? WHERE id = ?""", [roleId, userId])
		self.db.commit()

if __name__ == '__main__':
	qt = QGuiApplication(sys.argv)
	engine = QQmlApplicationEngine()

	# Instance of the Python object
	app = App()

	# Expose the Python object to QML
	context = engine.rootContext()
	context.setContextProperty("app", app)

	# Get the path of the current directory, and then add the name
	# of the QML file, to load it.
	qmlFile = join(dirname(__file__), 'app.qml')
	engine.load(abspath(qmlFile))

	if not engine.rootObjects():
		sys.exit(-1)

	sys.exit(qt.exec_())
