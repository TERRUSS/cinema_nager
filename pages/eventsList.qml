import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

ListView {
	id: listEvents
	Layout.fillWidth: true
	Layout.fillHeight: true
	verticalLayoutDirection: ListView.TopToBottom
	spacing: 12
	add: Transition {
		NumberAnimation { properties: "x,y"; from: 100; duration: 1000 }
	}
	model: events

	Component.onCompleted: {
		updateEvents()
	}

		// view init & utils funcs
	property var currentEvent: {
		"id": -1, "name": null,
		"date": null, "isOver": null,
		"room": null, "stuff": null,
		"stewart": null, "guests": null
	}
	function updateCurrEvent(id){
		if (id > -1){
			app.selectEvent(id)
			currentEvent = app.getCurrentEvent()
		} else {
			currentEvent = {   
				"id": -1, "name": null,
				"date": null, "isOver": null,
				"room": null, "stuff": null,
				"stewart": null, "guests": null
			}
		}
	}
	property var events: [{
			"id": -1, "name": null,
			"date": null, "isOver": null,
			"room": null, "stuff": null,
			"stewart": null, "guests": null
		}]
	function updateEvents(){
		events = app.getEvents()
	}

	function genEditedEvent(){
		return {
			"id": currentEvent.id, "name": edit_name.text,
			"date": edit_date.text,
			"room": edit_room.checked, "stuff": edit_stuff.checked,
			"stewarts": edit_stewart.checked, "guests": edit_guests.checked
		}
	}

	delegate: Column {
		anchors.leftMargin: 25
		spacing: 6
		Row {
			id: event
			spacing: 6


			Label {
				id: timestampText
				text: modelData.date

				font.capitalization: Font.AllUppercase
				font.pixelSize: 10
				font.weight: Font.Thin
				color: "lightgrey"
				anchors.right: undefined
			}

			Rectangle {
				id: rect
				width: window.width-timestampText.width*2-10
				height: filmDatas_.implicitHeight + 24
				radius: 5
				color: "#ff627c"
				
				Label {
					id: filmDatas_
					text: "TITRE\nREALISATEUR\nCATEGORIE "
					font.weight: Font.Light
					anchors.fill: parent
					anchors.margins: 12
				}

				Rectangle {
					id: filmDatas
					anchors.fill: parent
					radius: 5
					anchors.leftMargin: 120
					anchors.left: filmDatas_.right

					Label {
						font.weight: Font.Thin
						color:"black"
						id: filmDatas_name
						text: modelData.name+"\n"+modelData.name+"real"+"\n"+modelData.name+"categ"
						font.capitalization: Font.Capitalize
						anchors.fill: parent
						anchors.margins: 12
					}
				}


				Rectangle {
					id: filmActions
					anchors.fill: parent
					radius: 5
					anchors.leftMargin: 300
					color: "lightgrey"
					Label {
						color:"white"
						id: filmActions_
						text: "ventes\nprix unitaire\ntotal ventes"
						font.capitalization: Font.AllUppercase
						anchors.fill: parent
						anchors.margins: 12
					}

					Label {
						color:"gray"
						id: filmActions_name
						text: "ventes\nprix unitaire\ntotal ventes"
						font.capitalization: Font.AllUppercase
						anchors.fill: parent
						anchors.margins: 12
						anchors.leftMargin: 130
					}
				}

				Rectangle {
					id: status
					anchors.fill: parent
					radius: 5
					anchors.leftMargin: 550

					Label {
						Material.foreground: modelData.isOver ? Material.Green : Material.Blue
						id: statusText
						text: modelData.isOver ? "status : terminé" : "status : en cours"
						font.capitalization: Font.AllUppercase
						anchors.margins: 12
						anchors.right: status.right
						anchors.topMargin: 20
					}

					Rectangle {
						color: "white"
						anchors.fill: parent
						anchors.topMargin: 30
						anchors.margins: 20

						Button {
							id: editBtn
							highlighted: true
							Material.accent: "#ff627c"
							text: "éditer"
							anchors.right: parent.right
							onClicked: {
								updateCurrEvent(modelData.id)
								popup.open()
							}
						}

						Button {
							id: fileButton
							text: "Responsables     "
								//draw a lil triangle arrow
							Canvas {
								x: parent.width - width +5
								y: parent.height- height -4
								implicitWidth: 40
								implicitHeight: 40
								onPaint: {
									var ctx = getContext("2d")
									ctx.fillStyle = "#fff"
									ctx.moveTo(15, 15)
									ctx.lineTo(width - 15, height / 2)
									ctx.lineTo(15, height - 15)
									ctx.closePath()
									ctx.fill()
								}
							}
							highlighted: true
							Material.accent: Material.Blue
							onClicked: menu.open()
							Menu {
								id: menu
								y: fileButton.height
								Repeater {
									model: modelData.managers
									MenuItem { text: modelData.name }
								}
							}
						}
					}
				}

			}
		}
	}
	Popup {
		id: popup
		width: 600
		height: 300
		x: Math.round((window.width - width) / 2)
		y: Math.round((window.height - height)/2) - 50
		modal: true
		focus: true
		closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
		padding: 20
		contentItem: Item{
			Label { 
				id: popuptitle
				color: "white"; 
				text: (currentEvent.id > -1) ? "Editer l'évènement" : "Nouvel évènement"

				font.capitalization: Font.AllUppercase
				font.pixelSize: 16
				font.weight: Font.Thin

				anchors.top: parent.top
				anchors.left: parent.left
			}

			ScrollView {
				anchors.top: popuptitle.bottom
				clip: true
					ColumnLayout {
					id: mainLayout
					RowLayout {
						Label { color: "white"; text: "Nom" }
						TextField { color: "white"; id: edit_name; Layout.fillWidth: true;
							text: currentEvent.name
							font.capitalization: Font.Capitalize
						}
					}

					RowLayout {
						Label { color: "white"; text: "Date"}
						TextField { color: "white"; id: edit_date; Layout.fillWidth: true;
							text: currentEvent.date
							font.capitalization: Font.Capitalize
						}
					}

					RowLayout {
						CheckBox {
							id: edit_room
							checked: currentEvent.room
							text: qsTr("Salle")
						}
						CheckBox {
							id: edit_stuff
							checked: currentEvent.stuff
							text: qsTr("Matériel")
						}
						CheckBox {
							id: edit_stewart
							checked: currentEvent.stewart
							text: qsTr("Régie")
						}
						CheckBox {
							id: edit_guests
							checked: currentEvent.guests
							text: qsTr("Présence des invités")
						}
					}
				}

			}
			Button {
				id: editBtn
				highlighted: true
				Material.accent: "#ff627c"
				text: (currentEvent.id > -1) ? "Sauvegarder" : "Enregistrer"
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				onClicked: {
					app.saveEvent( genEditedEvent() )
					popup.close()
					updateEvents()
				}
			}
			Button {
				id: editBtn_close
				// highlighted: true
				Material.accent: "#ff627c"
				text: "Annuler"
				anchors.bottom: parent.bottom
				anchors.right: editBtn.left
				anchors.rightMargin: 10
				onClicked: {
					popup.close()
				}
			}

			Button {
				id: editBtn_delete
				highlighted: true
				visible: (currentEvent.id > -1) ? true : false
				Material.accent: "#ff5050"
				text: "Supprimer"
				anchors.bottom: parent.bottom
				anchors.left: parent.left
				onClicked: {
					popup.close()
				}
			}
		}
	}


	RoundButton {
		id: addButton
		text: "+" // icon-pencil
		Material.accent: "#ff5050"
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
			updateCurrEvent(-1)
			popup.open()
		}
	}

}