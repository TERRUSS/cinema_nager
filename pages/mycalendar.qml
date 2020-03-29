
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 1.4
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

import QtQuick.Controls.Styles 1.4

Page {
	background: Rectangle {
		color: "transparent"
	}

	Component.onCompleted: {
		updateCalendar()
	}

	id: calendarPage
	anchors.fill: parent
	property var multiSelectArr: [] //where I store the selected date range
	property var selectionStarted: false

	function initDayoffs(){
		multiSelectArr = []
	}

	function updateCalendar() {
	    multiSelectArr = app.getDaysOff(-1);
	    multiSelectArrChanged()
	}

	Calendar {
		anchors.fill: parent
		id: calendar
		selectedDate: new Date()
		weekNumbersVisible: true

		onClicked: {
			if (selectionStarted){
				if (multiSelectArr.indexOf(calendar.selectedDate.getTime()) == -1)
					multiSelectArr.push(calendar.selectedDate.getTime())
				else
					multiSelectArr.splice(multiSelectArr.indexOf(calendar.selectedDate.getTime()), 1)

				multiSelectArrChanged() // triggers array update
			}
		}
			// show calendar with juicy effects
		style: CalendarStyle {

			dayDelegate: Rectangle {
				color:	if (multiSelectArr.indexOf(styleData.date.getTime()) > -1)
							return "lightblue"; 
						else 
							return "white"
				Label {
					text: styleData.date.getDate()
					font.weight: ((styleData.date.getDate() == new Date().getDate()) && (styleData.date.getMonth() == new Date().getMonth())) ? Font.Bold : Font.Thin
					anchors.centerIn: parent
					color: styleData.valid ? "black" : "grey"
				}

			}

		}
	}

	Popup {
		id: popup
		width: 300
		height: 100
		x: Math.round((window.width - width) / 2)
		y: Math.round((window.height - height)/2) - 50
		modal: true
		focus: true
		closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
		padding: 20
		contentItem: ColumnLayout{
			Label {
				id: popupHint
				text: selectionStarted ? "Enregister les modificaions ?" : "Ajouter/Supprimer des day-offs ?"
				font.weight: Font.Thin
				font.pixelSize: 18
				color: "white"
			}

			RowLayout {
				spacing: 100
				Button {
					text: "Annuler"
					id: editBtn_close
					highlighted: true
					Material.accent: "#ff5050"
					onClicked: {
						if (selectionStarted){
							addButton.text = "+"
							addButton.Material.accent = "#5050ff"
							initDayoffs()
						}
						popup.close()
					}
				}

				Button {
					id: editBtn_delete
					highlighted: true
					Material.accent: "#509950"
					text: selectionStarted ? "OK" : "Oui"
					onClicked: {
						if (selectionStarted){
							addButton.text = "+"
							addButton.Material.accent = "#5050ff"
							app.saveDaysOff( multiSelectArr )
						}
						else{
							addButton.text = "✔"
							addButton.Material.accent = "#509950"
						}

						selectionStarted = !selectionStarted
						popup.close()
					}
				}
			}
		}
	}


	RoundButton {
		id: addButton
		text: "+" // icon-pencil
		Material.accent: "#5050ff"
		font.pixelSize: 30
		width: 80
		height: width
		// Don't want to use anchors for the y position, because it will anchor
		// to the footer, leaving a large vertical gap.
		y: parent.height - height - 12
		anchors.right: parent.right
		anchors.margins: 12
		highlighted: true

		onClicked: {
			popup.open()
		}
	}
}