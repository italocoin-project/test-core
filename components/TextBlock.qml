import QtQuick 2.0

import "../components" as ItalocoinComponents

TextEdit {
    color: ItalocoinComponents.Style.defaultFontColor
    font.family: ItalocoinComponents.Style.fontRegular.name
    selectionColor: ItalocoinComponents.Style.dimmedFontColor
    wrapMode: Text.Wrap
    readOnly: true
    selectByMouse: true
    // Workaround for https://bugreports.qt.io/browse/QTBUG-50587
    onFocusChanged: {
        if(focus === false)
            deselect()
    }
}
