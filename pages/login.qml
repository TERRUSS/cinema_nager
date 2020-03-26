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

        Button {
            id: loginButton
            highlighted: true
            Material.accent: "#ff627c"
            text: "Login"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            onClicked: {
                if ( app.login(userName.text, password.text) )
                    drawerBtn.visible = true
                    logoutBtn.visible = true
                    content.source = './eventsList.qml'
                    titleLabel.text = 'Liste des évènements'
                    listView.currentIndex = 0
                    // listEvents.append({"cost": 5.95, "name":"Pizza"})
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
}