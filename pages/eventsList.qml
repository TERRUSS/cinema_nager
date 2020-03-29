import QtQuick.Controls 2.12

import QtQuick 2.0
import QtQuick 2.12

import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

import QtQuick.Controls.Styles 1.4

import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 1.4
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

import QtQuick.Controls.Styles 1.4

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
		"stewart": null, "guests": null,
		"managers": [],
		"realisator": null,
		"category": null,
		"price": 0, "places": 0,
		"sold": 0,
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
				"stewart": null, "guests": null,
				"managers": [],
				"realisator": null,
				"category": null,
				"price": null, "places": null,
				"sold": null,
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

		console.log(currentEvent.managers)

		return {
			"id": currentEvent.id, "name": edit_name.text,
			"date": currentEvent.date,
			"room": edit_room.checked, "stuff": edit_stuff.checked,
			"stewarts": edit_stewart.checked, "guests": edit_guests.checked,
			"managers": currentEvent.managers,
			"realisator": edit_realisator.text,
			"category": edit_category.text,
			"price": edit_price.text, "places": edit_places.value,
			"sold": edit_sold.value,
		}
	}

	function dispDate(inputFormat) {
		function pad(s) { return (s < 10) ? '0' + s : s; }
		var d = new Date(inputFormat)
		return [pad(d.getDate()), pad(d.getMonth()+1), d.getFullYear()].join('/')
	}

	delegate: Column {
		anchors.leftMargin: 25
		spacing: 6
		Row {
			id: event
			spacing: 6


			Label {
				id: timestampText
				text: dispDate(modelData.date)

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
						text: modelData.name+"\n"+modelData.realisator+"\n"+modelData.category
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
						text: modelData.sold+"/"+modelData.places+"\n"+modelData.price+"\n"+modelData.total+'€'
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
							enabled: (app.getUserInfo().roleID == 3 || modelData.managers.indexOf(app.getUserInfo().id) > -1) ? true : false
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
									MenuItem { text: app.getUserName(modelData) }
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
		height: 500
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
				width: 550
				height: 400
				anchors.top: popuptitle.bottom
				clip: true
				
				ColumnLayout {
					ScrollBar.vertical: ScrollBar { }
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
						// TextField { color: "white"; id: edit_date; Layout.fillWidth: true;
						// 	text: currentEvent.date
						// 	font.capitalization: Font.Capitalize
						// }
						Button {
							id: toggledatepicker
							text: currentEvent.date ? dispDate(currentEvent.date) :"Date Picker"
							visible: true
							onClicked: {
								toggledatepicker.visible = false
								datepicker.visible = true
							}
						}
						Rectangle{
							id: datepicker
							visible: false
							clip: true
							height: 250
							width: 300
							Calendar {
								id: calendar
								selectedDate: currentEvent.date ? new Date(currentEvent.date) : new Date()
								weekNumbersVisible: true
								onClicked: {
									currentEvent.date = calendar.selectedDate.getTime()
									toggledatepicker.visible = true
									datepicker.visible = false
								}
							}
						}

					}

					RowLayout {
						Label { color: "white"; text: "Realisateur"}
						TextField { color: "white"; id: edit_realisator; Layout.fillWidth: true;
							text: currentEvent.realisator
							font.capitalization: Font.Capitalize
						}
					}

					RowLayout {
						Label { color: "white"; text: "Catégorie"}
						TextField { color: "white"; id: edit_category; Layout.fillWidth: true;
							text: currentEvent.category
							font.capitalization: Font.Capitalize
						}
					}

					RowLayout {
						Label { color: "white"; text: "Prix unitaire"}
						TextField { color: "white"; id: edit_price; Layout.fillWidth: true;
							text: currentEvent.price
							font.capitalization: Font.Capitalize
						}
					}

					RowLayout {
						Label { color: "white"; text: "Places disponibles"}
						SpinBox {
							id: edit_places
							value: currentEvent.places
						}
					}

					RowLayout {
						Label { color: "white"; text: "Places vendues"}
						SpinBox {
							id: edit_sold
							value: currentEvent.sold
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

					Item {

							width: 500

						ComboBox {
							id: comboBox
							width: 500

							displayText: "Responsables de l'évenement"

							model: app.getUsers()

							// ComboBox closes the popup when its items (anything AbstractButton derivative) are
							//  activated. Wrapping the delegate into a plain Item prevents that.
							delegate: Item {
								width: parent.width
								height: checkDelegate.height

								function toggle() { checkDelegate.toggle() }

								CheckDelegate {
									id: checkDelegate
									anchors.fill: parent
									text: modelData.name
									font.capitalization: Font.Capitalize
									highlighted: comboBox.highlightedIndex == index
									checked: currentEvent.managers.indexOf(modelData.id) > -1
									onCheckedChanged: {
										if (!checkDelegate.checked) {
											console.log('-')
											currentEvent.managers.splice(currentEvent.managers.indexOf(modelData.id), 1) 
										}
										else {
											console.log('+')
											currentEvent.managers.push(modelData.id)
										}
										console.log(currentEvent.managers)
									}
								}
							}
						}
					}
					Rectangle{
						height: 50
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
		visible: (app.getUserInfo().roleID == 3) ? true : false
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