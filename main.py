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
			#Create tables
		cursor.execute("""
			CREATE TABLE IF NOT EXISTS users(
				id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
				login TEXT UNIQUE,
				password TEXT,
				role INTEGER DEFAULT 1
			)""")
		cursor.execute("""
			CREATE TABLE IF NOT EXISTS roles(
				id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
				role TEXT
			)""")
		cursor.execute("""
			CREATE TABLE IF NOT EXISTS events(
				id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
				isMovie BOOLEAN DEFAULT 0,
				name TEXT,
				realisator TEXT,
				category TEXT,
				date DATE,
				isOver BOOLEAN,
				room BOOLEAN,
				stuff BOOLEAN,
				stewarts BOOLEAN,
				managersIDs TEXT
			)""")
		self.db.commit()

			#Add roles
		roles = [["Mairie"], ["Membre d' équipe"], ["Administrateur"]]
		cursor.executemany('INSERT INTO roles(role) VALUES (?)', roles)
		
		self.db.commit()


		# bindings with the view (qml)
	@Slot(str, str, result=bool)
	def login(self, login, passwd):
		logging.info(f'[LOGIN] from : {login}')

		cursor = self.db.cursor()
		cursor.execute("""
			SELECT users.id, users.login, roles.role
			FROM users
			LEFT JOIN roles ON roles.id = users.role
			WHERE login = ? AND password = ?""", [login, passwd])
		result = cursor.fetchone()

		if (result):
			logging.info("[LOGIN] success")
			self.user = {
				"id": result[0],
				"name": result[1],
				"role": result[2]
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

	@Slot(result="QVariantList")
	def getEvents(self):
		logging.info(f'[EVENTS] Get events')

		cursor = self.db.cursor()
		res = cursor.execute("""SELECT * FROM events""")

		events = []
		for e in events:
			events.push({
				"id": e[0], "isMovie": e[1], "name": e[2],
				"realisator": e[3], "category": e[4],
				"date": e[5], "isOver": e[6], "room": e[7],
				"stuff": e[8], "stewart": e[9], "managersIDs": e[10]
			})
		print(events)

		return self.events

	@Slot("QJSValue")
	def saveEvent(self, newevent):
		logging.info(f'[EVENTS] Save event')
		newevent = newevent.toVariant()

		print(newevent)

		event_formatted = (v for k, v in newevent.items() if k =! 'id')
		
		if (newevent['id']<= 0): #if its a ne event
			cursor = self.db.cursor()
			cursor.execute("""
				INSERT INTO events (date, guests, name, room, stewarts, stuff)
				VALUES(?, ?)""", event_formatted)
			self.db.commit()

		else:
			cursor = self.db.cursor()
			cursor.execute("""
				UPDATE events SET date= ?, guests= ?, name= ?, room = ?,
				stewarts = ?, stuff = ?
				WHERE id = ?""", event_formatted + newevent['id'])
			self.db.commit()


	@Slot(result="QVariant")
	def getUserInfo(self):
		logging.info(f'[APP] Get user infos')
		print(self.user)
		return self.user

	@Slot(result="QVariant")
	def getCurrentEvent(self):
		logging.info(f'[EVENTS] Get current event')
		return self.events[self.currentEvent]

	@Slot(int, result="QVariant")
	def selectEvent(self, id):
		logging.info(f'[EVENTS] Set current event ({id})')
		self.currentEvent = id




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
