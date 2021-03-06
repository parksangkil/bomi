import QtQuick 2.0
import bomi 1.0 as B
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0

Item {
    id: player
    objectName: "player"
    property real dockZ: 0.0
    property real bottomPadding: 0.0
    readonly property QtObject engine: B.App.engine

    Logo { anchors.fill: parent }

    TextOsd {
        id: msgosd;
        duration: B.App.theme.osd.message.duration
    }

    Rectangle {
        id: msgbox
        color: Qt.rgba(0.86, 0.86, 0.86, 0.8)
        visible: false
        anchors.centerIn: parent
        width: boxmsg.width + pad*2
        height: boxmsg.height + pad*2
        readonly property real pad: 5
        Text {
            id: boxmsg
            anchors.centerIn: parent
            width: contentWidth
            height: contentHeight
            font.bold: true
        }
        radius: 5
        border.color: "black"
        border.width: 1
    }

    ProgressOsd {
        id: timeline; value: engine.rate
        duration: B.App.theme.osd.timeline.duration
        x: (parent.width - width)*0.5
        y: {
            var m = B.App.theme.osd.timeline.margin
            switch (B.App.theme.osd.timeline.position) {
            case B.TimelineTheme.Top:
                return parent.height * m;
            case B.TimelineTheme.Bottom:
                return parent.height * (1.0 - m) - height;
            default:
                return (parent.height - height)*0.5;
            }
        }
    }
    PlayInfoView { objectName: "playinfo" }
    Item {
        anchors.fill: parent; z: dockZ
        PlaylistDock {
            id: right
            show: B.App.playlist.visible
            width: Math.min(widthHint, player.width-(left.x+left.width)-20)
            height: parent.height-2*y - bottomPadding
        }
        HistoryDock {
            id: left
            show: B.App.history.visible
            width: Math.min(widthHint, player.width*0.4)
            height: parent.height-2*y - bottomPadding
        }
    }
    Component.onCompleted: {
        engine.screen.parent = player
        engine.screen.width = width
        engine.screen.height = height
    }
    onWidthChanged: engine.screen.width = width
    onHeightChanged: engine.screen.height = height

    property var showOsdFunc: function(msg){ msgosd.text = msg; msgosd.show(); }
    function showOSD(msg) { showOsdFunc(msg) }
    function showMessageBox(msg) { msgbox.visible = !!msg; boxmsg.text = msg }
    function showTimeLine() { timeline.show(); }

    B.MessageBox {
        id: downloadMBox
        parent: B.App.topLevelItem
        width: 300
        height: 100
        anchors.centerIn: parent
        title.text: qsTr("Download")
        message.text: B.App.download.url
        message.elide: Text.ElideMiddle
        message.verticalAlignment: Text.AlignVCenter
        visible: false
        Connections {
            target: B.App.download
            onRunningChanged: {
                downloadMBox.visible = B.App.download.running
                if (B.App.download.running)
                    B.App.topLevelItem.visible = true
                else
                    B.App.topLevelItem.check()
            }
        }
        buttonBox.buttons: [B.ButtonBox.Cancel]
        buttonBox.onClicked: {
            if (button == B.ButtonBox.Cancel)
                B.App.download.cancel()
        }

        readonly property QtObject download: B.App.download
        customItem: B.ProgressBar {
            id: prog
            value: B.App.download.rate
            property bool writing: B.App.download.writtenSize >= 0
            function sizeText(size) {
                if (size < 0)
                    return "??"
                if (size < 1024*1024)
                    return (size/1024).toFixed(3) + "KiB"
                return (size/(1024*1024)).toFixed(3) + "MiB"
            }
            Text {
                height: parent.height
                anchors.right: progSlash.left
                anchors.rightMargin: 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                color: "black"
                visible: prog.writing
                text: prog.sizeText(B.App.download.writtenSize)
            }
            Text {
                id: progSlash
                anchors.horizontalCenter: parent.horizontalCenter
                width: 5; height: parent.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: "black"
                text: prog.writing ? "/" : qsTr("Connecting...")
            }
            Text {
                height: parent.height
                anchors.left: progSlash.right
                anchors.leftMargin: 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                color: "black"
                visible: prog.writing
                text: prog.sizeText(B.App.download.totalSize)
            }
        }
    }

    property var mouse: B.App.window.mouse

    MouseArea {
        id: rightEdge
        visible: B.App.theme.playlist.showOnMouseOverEdge
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: 15; z: 1e10; hoverEnabled: true
        onContainsMouseChanged: {
            if (containsMouse) {
                B.App.playlist.visible = true
                rightTimer.run()
            }
        }
        B.HideTimer {
            id: rightTimer
            target: B.App.playlist
            hide: function() { return !mouse.isIn(right) }
        }
    }
    MouseArea {
        id: leftEdge
        visible: B.App.theme.history.showOnMouseOverEdge
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: 15; z: 1e10; hoverEnabled: true
        onContainsMouseChanged: {
            if (containsMouse) {
                B.App.history.visible = true
                leftTimer.run()
            }
        }
        B.HideTimer {
            id: leftTimer; target: B.App.history
            hide: function() { return !mouse.isIn(left) }
        }
    }
}
