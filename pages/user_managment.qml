import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

Page {
	property var selectedUserRole: -1
	property var selectedUserId: -1
	padding: 20
	Label {
		padding: 10
		id: selectioLabel
		text: "Selectionner un utilisateur pour modifier ses droits\n"
		color: "white"
		font.capitalization: Font.AllUppercase
		font.pixelSize: 16
		font.weight: Font.Thin

		RowLayout {
			anchors.bottom: parent.bottom
			spacing: 50
			Label{
				text: "Nom"
				font.capitalization: Font.AllUppercase
				font.weight: Font.Thin
			}

			Label{
				text: "Role"
				font.capitalization: Font.AllUppercase
			}
		}
	}

	ListView {
		id: listView
		currentIndex: -1
		anchors.fill: parent
		anchors.topMargin: selectioLabel.height + 20

		delegate: ItemDelegate {
			width: parent.width
			onClicked: {
				selectedUserRole = modelData.roleID
				selectedUserId = modelData.id
				popup.open()
			}
			highlighted: ListView.isCurrentItem

			
			RowLayout {
				spacing: 50

				Label{
					text: modelData.name
					font.capitalization: Font.Capitalize
					font.weight: Font.Thin
				}

				Label{
					text: modelData.role
					font.capitalization: Font.Capitalize
					font.weight: Font.Thin
				}
			}
		}

		model: app.getUsers()

		ScrollIndicator.vertical: ScrollIndicator { }
	}

	Popup {
		id: popup
		width: 500
		height: 200
		x: Math.round((window.width - width) / 2)
		y: Math.round((window.height - height)/2) - 50
		modal: true
		focus: true
		closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
		padding: 20
		contentItem: ColumnLayout{
			Row {
				id: column

				Repeater {
					model: app.getRoles()
					RadioButton {
						checked: (modelData.id == selectedUserRole) ? true : false
						text: modelData.role
						onClicked: {
							selectedUserRole = modelData.id
						}
					}
				}
			}

			RowLayout {
				spacing: 300
				Button {
					text: "Annuler"
					id: editBtn_close
					highlighted: true
					Material.accent: "#ff5050"
					onClicked: {
						popup.close()
					}
				}

				Button {
					id: editBtn_delete
					highlighted: true
					Material.accent: "#509950"
					text: "Valider"
					onClicked: {
						app.updateRole([selectedUserId, selectedUserRole])
						popup.close()
					}
				}
			}
		}
	}

}