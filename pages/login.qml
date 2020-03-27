import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

Item {
	id: login
	property alias userName: userName
	property alias loginButton: loginButton
	property alias nameInUseError: nameInUseError

	ColumnLayout {
		anchors.centerIn: parent
		TextField {
			id: userName
			Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
			placeholderText: "Username"
		}
		TextField {
			id: password
			Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
			placeholderText: "Password"
			echoMode: TextInput.PasswordEchoOnEdit
		}

		Row {
			spacing: 20
			Button {
				id: loginButton
				highlighted: true
				Material.accent: "#ff627c"
				text: "Login"
				onClicked: {
					if ( app.login(userName.text, password.text) ) {
						drawerBtn.visible = true
						logoutBtn.visible = true
						content.source = './eventsList.qml'
						titleLabel.text = 'Liste des évènements'
						listView.currentIndex = 0
						// listEvents.append({"cost": 5.95, "name":"Pizza"})
					} else {
						nameInUseError.visible = true
					}
				}
			}

			Button {
				id: creataccountBtn
				highlighted: true
				Material.accent: Material.Blue
				text: "Register"
				onClicked: {
					popupSignup.open()
				}
			}
		}

		Label {
			id: nameInUseError
			visible: false
			Material.foreground: Material.Red
			text: "Erreur, réessayez"
			Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		}
	}

	Popup {
		id: popupSignup
		width: 300
		height: 200
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
				text: "Sign In"

				font.capitalization: Font.AllUppercase
				font.pixelSize: 16
				font.weight: Font.Thin

				anchors.top: parent.top
				anchors.horizontalCenter: parent.horizontalCenter

				Label {
					anchors.horizontalCenter: parent.horizontalCenter
					id: errUserExists
					visible: false
					Material.foreground: Material.Red
					text: "L'utilisateur existe déjà"
					font.pixelSize: 10
					Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
					anchors.top: popuptitle.bottom
				}
			}

			GridLayout {
				anchors.top: popuptitle.bottom				
				anchors.topMargin: 10				
					ColumnLayout {
					id: mainLayout
					RowLayout {
						Label { color: "white"; text: "Login" }
						TextField { color: "white"; id: signup_login; Layout.fillWidth: true;
							text: ""
						}
					}

					RowLayout {
						Label { color: "white"; text: "Password"}
						TextField { color: "white"; id: signup_pw; Layout.fillWidth: true;
							text: ""
							echoMode: TextInput.PasswordEchoOnEdit
						}
					}

				}

			}
			Button {
				id: editBtn
				highlighted: true
				Material.accent: "#ff627c"
				text: "Sign up"
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				onClicked: {
					if (app.signin(signup_login.text, signup_pw.text))
						popupSignup.close()
					else
						errUserExists.visible = true
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
					popupSignup.close()
				}
			}
		}
	}
}