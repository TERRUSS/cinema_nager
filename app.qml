import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Universal 2.0
import Qt.labs.settings 1.0

import QtQuick.Window 2.12

ApplicationWindow {
	id: window
	width: 900
	height: 600
	maximumHeight: height
	maximumWidth: width
	minimumHeight: height
	minimumWidth: width

	color: "#101010"
	
	visible: true
	title: "Cinéma-nager"
	// Material.background: '#101010'


	header: ToolBar {
		background: Rectangle {
			color: "transparent"
		}
		height: 100
		Material.primary: "#101010"
		RowLayout {
			spacing: 20
			anchors.fill: parent

			ToolButton {
				id: drawerBtn
				visible: false
				contentItem: Image {
					fillMode: Image.Pad
					horizontalAlignment: Image.AlignHCenter
					verticalAlignment: Image.AlignVCenter
					source: "./assets/drawer30.png"
				}
				onClicked: drawer.open()
			}

			Label {
				id: titleLabel
				text: "Login"
				font.capitalization: Font.AllUppercase
				font.pixelSize: 30
				font.weight: Font.Thin
				elide: Label.ElideRight
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
				Layout.fillWidth: true
			}

			ToolButton {
				id: logoutBtn
				visible: false
				contentItem: Image {
					fillMode: Image.Pad
					horizontalAlignment: Image.AlignHCenter
					verticalAlignment: Image.AlignVCenter
					source: "./assets/logout30.png"
				}
				onClicked: {
					content.source = './pages/login.qml'
					titleLabel.text = "login"
					listView.currentIndex = -1
					drawerBtn.visible = false
					logoutBtn.visible = false
				}
				// Menu {
				//     id: optionsMenu
				//     x: parent.width - width
				//     transformOrigin: Menu.TopRight

				//     MenuItem {
				//         text: "Settings"
				//         onTriggered: settingsPopup.open()
				//     }
				//     MenuItem {
				//         text: "About"
				//         onTriggered: aboutDialog.open()
				//     }
				// }
			}
		}
	}

	Drawer {
		id: drawer
		width: Math.min(window.width, window.height) / 3 * 2
		height: window.height

		Rectangle {
			id: drawerheader
			color: "#ff627c"
			radius: 5
			anchors.margins: 20
			// anchors.fill: parent
			width: parent.width
			anchors.topMargin: 10
			height: 100
			Label {
				text: "Bonjour,"
				anchors.fill: parent
				anchors.margins: 12
				font.weight: Font.Thin
			}
			Label {
				anchors.topMargin: 30
				anchors.margins: 12
				text: app.getUserInfo().name
				anchors.fill: parent
				font.weight: Font.Light
				font.pixelSize: 20
			}

			Label {
				anchors.topMargin: 70
				anchors.margins: 12
				text: "Vous êtes " + app.getUserInfo().role
				anchors.fill: parent
				font.weight: Font.Light
			}
		}

		ListView {
			id: listView
			currentIndex: -1
			anchors.fill: parent
			anchors.topMargin: drawerheader.height + 20

			delegate: ItemDelegate {
				width: parent.width
				text: model.title
				font.capitalization: Font.AllUppercase
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


	// CONTENT
	Loader {
		anchors.fill: parent
		id: content
		source: "./pages/login.qml"
	}
}