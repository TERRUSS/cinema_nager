
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 1.4
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

import QtQuick.Controls.Styles 1.4

SplitView {
	id: calendarPage
	anchors.fill: parent
	property var multiSelectArr: [] //where I store the selected date range
	property var selectionStarted: false

	function initDayoffs(){
		multiSelectArr = []
	}

	function updateCalendar(id) {
	    multiSelectArr = app.getDaysOff(id);
	    multiSelectArrChanged()
	}

	Calendar {
		// anchors.fill: parent
		width: window.width*3/4
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

	Rectangle {
		color: "transparent"
		Label {
			padding: 10
			id: selectioLabel
			text: "Selectionner un membre \nci-dessous pour voir son \nemploi du temps"
			color: "white"
			font.capitalization: Font.AllUppercase
			font.pixelSize: 16
			font.weight: Font.Thin
		}
		ListView {
			id: listView
			currentIndex: -1
			anchors.fill: parent
			anchors.topMargin: selectioLabel.height + 20

			delegate: ItemDelegate {
				width: parent.width
				text: modelData.name
				font.capitalization: Font.Capitalize
				font.weight: Font.Thin
				highlighted: ListView.isCurrentItem
				onClicked: {
					updateCalendar(modelData.id)
					drawer.close()
				}
			}

			model: app.getUsers()

			ScrollIndicator.vertical: ScrollIndicator { }
		}
	}
}