
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
			text: model.title
			font.capitalization: Font.Capitalize
			font.weight: Font.Thin
			highlighted: ListView.isCurrentItem
			onClicked: {
				if (listView.currentIndex != index) {
					listView.currentIndex = index
					titleLabel.text = model.title
					// content.replace(model.source)
					content.source = model.source
				}
				drawer.close()
			}
		}

		model: ListModel {
			ListElement { title: "évènements"; source: "./pages/eventsList.qml" }
			ListElement { title: "mon calendrier"; source: "./pages/mycalendar.qml" }
			ListElement { title: "calendrier équipes"; source: "./pages/squad_calendar.qml" }
		}

		ScrollIndicator.vertical: ScrollIndicator { }
	}
	}
}