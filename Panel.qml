import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Commons

Item {
  id: root
  property var shell: null
  property var manifest: null
  property bool opened: false
  readonly property var workspaces: usedWorkspaces()
  property int selected: 0
  readonly property int columns: workspaces.length > 4 ? 3 : 2

  function usedWorkspaces() {
    var result = []
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var workspace = values[i]
      if (workspace.id > 0 && workspace.toplevels.values.length > 0)
        result.push({ id: workspace.id, windows: workspace.toplevels.values })
    }
    result.sort(function(a, b) { return a.id - b.id })
    return result
  }

  function open() {
    opened = true
    var activeId = activeWorkspaceId()
    selected = 0
    for (var i = 0; i < workspaces.length; i++) {
      if (workspaces[i].id === activeId) { selected = i; break }
    }
    Qt.callLater(function() { if (opened) keyArea.forceActiveFocus() })
  }

  function close() { opened = false }

  function dismiss() {
    if (shell && typeof shell.hide === "function") shell.hide(manifest.id)
    else close()
  }

  function activeWorkspaceId() {
    return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
  }

  function captureHandle(window) {
    if (window.handle) return window.handle
    var all = ToplevelManager.toplevels.values
    for (var i = 0; i < all.length; i++) {
      var associated = all[i].HyprlandToplevel.handle
      if (associated && associated.address === window.address) return all[i]
    }
    return null
  }

  function move(step) {
    if (workspaces.length > 0)
      selected = (selected + step + workspaces.length) % workspaces.length
  }

  function choose(id) {
    if (id <= 0) return
    Hyprland.dispatch("hl.dsp.focus({ workspace = \"" + id + "\" })")
    dismiss()
  }

  PanelWindow {
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "omarchy-workspace-switcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle {
      anchors.fill: parent
      color: Color.menu.scrim
      MouseArea { anchors.fill: parent; onClicked: root.dismiss() }
    }

    Item {
      id: keyArea
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: root.dismiss()
      Keys.onLeftPressed: root.move(-1)
      Keys.onUpPressed: root.move(-1)
      Keys.onRightPressed: root.move(1)
      Keys.onDownPressed: root.move(1)
      Keys.onTabPressed: root.move(1)
      Keys.onBacktabPressed: root.move(-1)
      Keys.onReturnPressed: if (root.workspaces[root.selected]) root.choose(root.workspaces[root.selected].id)
      Keys.onEnterPressed: if (root.workspaces[root.selected]) root.choose(root.workspaces[root.selected].id)

      Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - Style.space(32), Style.space(1000))
        implicitHeight: content.implicitHeight + Style.space(48)
        height: implicitHeight
        scale: Math.min(1, (keyArea.height - Style.space(32)) / Math.max(1, height))
        radius: Style.cornerRadius
        color: Color.popups.background
        border.color: Color.popups.border
        border.width: 1

        MouseArea { anchors.fill: parent; onClicked: {} }

        ColumnLayout {
          id: content
          anchors.fill: parent
          anchors.margins: Style.space(24)
          spacing: Style.space(18)

          Text {
            text: "WORKSPACES EM USO"
            color: Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 2
            Layout.fillWidth: true
          }

          Item {
            id: workspaceGrid
            Layout.fillWidth: true
            readonly property real gap: Style.space(10)
            readonly property int rows: Math.ceil(root.workspaces.length / root.columns)
            readonly property real tileWidth: Math.min(Style.space(440),
              (width - gap * (root.columns - 1)) / root.columns)
            readonly property real tileHeight: tileWidth * 0.62
            implicitHeight: rows > 0 ? rows * tileHeight + (rows - 1) * gap : 0

            Repeater {
              model: root.workspaces
              delegate: Rectangle {
                required property var modelData
                required property int index
                readonly property var workspaceData: modelData
                readonly property bool highlighted: index === root.selected
                readonly property int row: Math.floor(index / root.columns)
                readonly property int cardsInRow: Math.min(root.columns,
                  root.workspaces.length - row * root.columns)
                width: workspaceGrid.tileWidth
                height: workspaceGrid.tileHeight
                x: (workspaceGrid.width - cardsInRow * width
                  - (cardsInRow - 1) * workspaceGrid.gap) / 2
                  + (index % root.columns) * (width + workspaceGrid.gap)
                y: row * (height + workspaceGrid.gap)
                radius: Style.cornerRadius
                color: highlighted ? Color.menu.selectedBackground : Color.background
                border.color: highlighted ? Color.accent : Color.popups.border
                border.width: highlighted ? 2 : 1

                ColumnLayout {
                  anchors.fill: parent
                  anchors.margins: Style.space(8)
                  spacing: Style.space(7)

                  Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Math.max(2, Style.cornerRadius - Style.space(4))
                    color: Color.background
                    clip: true

                    Grid {
                      anchors.fill: parent
                      columns: workspaceData.windows.length === 1 ? 1 : 2
                      spacing: Style.space(2)

                      Repeater {
                        model: workspaceData.windows.slice(0, 4)

                        delegate: Item {
                          required property var modelData
                          readonly property var previewWindow: modelData
                          width: (parent.width - (parent.columns - 1) * parent.spacing) / parent.columns
                          height: workspaceData.windows.length <= 2
                            ? parent.height
                            : (parent.height - parent.spacing) / 2
                          clip: true

                          ScreencopyView {
                            anchors.fill: parent
                            captureSource: root.opened ? root.captureHandle(previewWindow) : null
                            live: false
                            paintCursor: false
                          }
                        }
                      }
                    }
                  }

                  RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.space(8)
                    Text {
                      text: String(workspaceData.id)
                      color: highlighted ? Color.menu.selectedText : Color.popups.text
                      font.family: Style.font.family
                      font.pixelSize: Style.font.body
                      font.bold: true
                    }
                    Text {
                      text: workspaceData.windows[0] ? workspaceData.windows[0].title : ""
                      color: Color.muted
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      elide: Text.ElideRight
                      Layout.fillWidth: true
                    }
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onEntered: root.selected = index
                  onClicked: root.choose(workspaceData.id)
                }
              }
            }
          }

          Text {
            visible: root.workspaces.length === 0
            text: "Nenhum workspace com janelas abertas"
            color: Color.muted
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            Layout.fillWidth: true
          }

          Text {
            text: "← → / Tab para navegar  ·  Enter para abrir  ·  Esc para fechar"
            color: Color.muted
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            Layout.fillWidth: true
            wrapMode: Text.Wrap
          }
        }
      }
    }
  }
}
