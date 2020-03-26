import sys
from os.path import abspath, dirname, join

from PySide2.QtCore import QObject, Slot
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine

from style_rc import *

import logging
logging.basicConfig(level=logging.INFO)


import sqlite3

class App(QObject):

	def __init__(self):
		self.events = [
			{   "id": 0, "name": "bonjour",
				"date": "21 Sept", "isOver": True,
				"room": True, "stuff": True,
				"stewart": True, "guests": True,
				"managers": [{"name": "Jean Guy"}, {"name": "Madeleine"}]
			}, 
			{   "id": 1, "name": "au revoir",
				"date": "27 Oct", "isOver": False,
				"room": False, "stuff": False,
				"stewart": True, "guests": True,
				"managers": [{"name": "Jean Guy"}, {"name": "Madeleine"}, {"name": "Zippy"}]
			}, 
		]
		self.currentEvent = 0

			# DB
		self.db = sqlite3.connect('ma_base.db')
		initDB()

	def __del__(self):
		self.db.close()



	def initDB():
		cursor = self.db.cursor()
		cursor.execute("""
			CREATE TABLE IF NOT EXISTS users(
			     id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
			     name TEXT,
			)
			""")
		self.db.commit()

		# bindings with the view (qml)
	@Slot(str, str, result=bool)
	def login(self, login, passwd):
		logging.info(f'[LOGIN] from : {login}')
		return True

	@Slot(str)
	def test_log(self, msg):
		logging.info(f'[TEST] {msg}')

	@Slot(result="QVariantList")
	def getEvents(self):
		logging.info(f'[EVENTS] Get events')
		return self.events

	@Slot(result="QVariant")
	def getUserInfo(self):
		logging.info(f'[APP] Get user infos')
		return {"name": "Audrey Tautou", "role": "Administrateur"}

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
