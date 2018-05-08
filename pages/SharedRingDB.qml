// Copyright (c) 2018, The Italocoin Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import "../components"
import italocoinComponents.Clipboard 1.0

Rectangle {
    property alias panelHeight: mainLayout.height
    color: "transparent"

    Clipboard { id: clipboard }

    function validHex32(s) {
        if (s.length != 64)
            return false
        for (var i = 0; i < s.length; ++i)
            if ("0123456789abcdefABCDEF".indexOf(s[i]) == -1)
                return false
        return true
    }

    function validRing(str, relative) {
        var outs = str.split(" ");
        if (outs.length == 0)
            return false
        for (var i = 1; i < outs.length; ++i) {
            if (relative) {
                if (outs[i] <= 0)
                    return false
            }
            else {
                if (outs[i] <= outs[i-1])
                    return false
            }
        }
        return true
    }

    /* main layout */
    ColumnLayout {
        id: mainLayout
        anchors.margins: (isMobile)? 17 : 20
        anchors.topMargin: 40 * scaleRatio
  
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20 * scaleRatio
        property int labelWidth: 120
        property int editWidth: 400
        property int lineEditFontSize: 14 * scaleRatio

        MessageDialog {
            id: sharedRingDBDialog
            standardButtons: StandardButton.Ok
        }

        Label {
            id: signTitleLabel
            fontSize: 24 * scaleRatio
            text: qsTr("Shared RingDB") + translationManager.emptyString
        }

        Text {
            text: qsTr("This page allows you to interact with the shared ring database. " +
                       "This database is meant for use by Italocoin wallets as well as wallets from Italocoin clones which reuse the Italocoin keys.") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.family: Style.fontRegular.name
            font.pixelSize: 14 * scaleRatio
            color: Style.defaultFontColor
        }

        LabelSubheader {
            Layout.fillWidth: true
            textFormat: Text.RichText
            text: "<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>" +
                  qsTr("Blackballed outputs") + " <a href='#'>" + qsTr("Help") + "</a>" + translationManager.emptyString
            onLinkActivated: {
                sharedRingDBDialog.title  = qsTr("Blackballed outputs") + translationManager.emptyString;
                sharedRingDBDialog.text = qsTr(
                    "In order to obscure which inputs in a Italocoin transaction are being spent, a third party should not be able " +
                    "to tell which inputs in a ring are already known to be spent. Being able to do so would weaken the protection " +
                    "afforded by ring signatures. If all but one of the inputs are known to be already spent, then the input being " +
                    "actually spent becomes apparent, thereby nullifying the effect of ring signatures, one of the three main layers " +
                    "of privacy protection Italocoin uses.<br>" +
                    "To help transactions avoid those inputs, a list of known spent ones can be used to avoid using them in new " +
                    "transactions. Such a list is maintained by the Italocoin project and is available on the getitalocoin.org website, " +
                    "and you can import this list here.<br>" +
                    "Alternatively, you can scan the blockchain (and the blockchain of key-reusing Italocoin clones) yourself " +
                    "using the italocoin-blockchain-blackball tool to create a list of known spent outputs.<br>"
                )
                sharedRingDBDialog.icon = StandardIcon.Information
                sharedRingDBDialog.open()
            }
        }

        Text {
            textFormat: Text.RichText
            font.family: Style.fontRegular.name
            font.pixelSize: 14 * scaleRatio
            text: qsTr("This sets which outputs are known to be spent, and thus not to be used as privacy placeholders in ring signatures. ") +
                  qsTr("You should only have to load a file when you want to refresh the list. Manual adding/removing is possible if needed.") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true;
            color: Style.defaultFontColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 12

            FileDialog {
                id: loadBlackballFileDialog
                title: qsTr("Please choose a file to load blackballed outputs from") + translationManager.emptyString;
                folder: "file://"
                nameFilters: [ "*"]

                onAccepted: {
                    loadBlackballFileLine.text = walletManager.urlToLocalPath(loadBlackballFileDialog.fileUrl)
                }
            }

            RowLayout {
                Layout.fillWidth: true

                LineEdit {
                    id: loadBlackballFileLine
                    Layout.fillWidth: true
                    fontSize: mainLayout.lineEditFontSize
                    placeholderText: qsTr("Path to file") + "..." + translationManager.emptyString
                    labelFontSize: 14 * scaleRatio
                    labelText: qsTr("Filename with outputs to blackball") + ":" + translationManager.emptyString
                    copyButton: true
                    readOnly: false
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 18

                StandardButton {
                    id: selectBlackballFileButton
                    anchors.rightMargin: 17 * scaleRatio
                    text: qsTr("Browse") + translationManager.emptyString
                    enabled: true
                    small: true
                    onClicked: {
                      loadBlackballFileDialog.open()
                    }
                }

                StandardButton {
                    id: loadBlackballFileButton
                    anchors.right: parent.right
                    text: qsTr("Load") + translationManager.emptyString
                    small: true
                    enabled: !!appWindow.currentWallet && loadBlackballFileLine.text !== ""
                    onClicked: appWindow.currentWallet.blackballOutputs(walletManager.urlToLocalPath(loadBlackballFileDialog.fileUrl), true)
                }
            }
        }

        ColumnLayout {
            Layout.topMargin: 12

            RowLayout {
                LineEdit {
                    id: blackballOutputLine
                    fontSize: mainLayout.lineEditFontSize
                    labelFontSize: 14 * scaleRatio
                    labelText: qsTr("Or manually blackball/unblackball a single output:") + translationManager.emptyString
                    placeholderText: qsTr("Paste output public key") + "..." + translationManager.emptyString
                    readOnly: false
                    copyButton: true
                    width: mainLayout.editWidth
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 18

                StandardButton {
                    id: blackballButton
                    text: qsTr("Blackball") + translationManager.emptyString
                    small: true
                    enabled: !!appWindow.currentWallet && validHex32(blackballOutputLine.text)
                    onClicked: appWindow.currentWallet.blackballOutput(blackballOutputLine.text)
                }

                StandardButton {
                    id: unblackballButton
                    anchors.right: parent.right
                    text: qsTr("Unblackball") + translationManager.emptyString
                    small: true
                    enabled: !!appWindow.currentWallet && validHex32(blackballOutputLine.text)
                    onClicked: appWindow.currentWallet.unblackballOutput(blackballOutputLine.text)
                }
            }
        }

        LabelSubheader {
            Layout.fillWidth: true
            Layout.topMargin: 24 * scaleRatio
            textFormat: Text.RichText
            text: "<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>" +
                  qsTr("Rings") + " <a href='#'>" + qsTr("Help") + "</a>" + translationManager.emptyString
            onLinkActivated: {
                sharedRingDBDialog.title  = qsTr("Rings") + translationManager.emptyString;
                sharedRingDBDialog.text = qsTr(
                    "In order to avoid nullifying the protection afforded by Italocoin's ring signatures, an output should not " +
                    "be spent with different rings on different blockchains. While this is normally not a concern, it can become one " +
                    "when a key-reusing Italocoin clone allows you do spend existing outputs. In this case, you need to ensure this " +
                    "existing outputs uses the same ring on both chains.<br>" +
                    "This will be done automatically by Italocoin and any key-reusing software which is not trying to actively strip " +
                    "you of your privacy.<br>" +
                    "If you are using a key-reusing Italocoin clone too, and this clone does not include this protection, you can still " +
                    "ensure your transactions are protected by spending on the clone first, then manually adding the ring on this page, " +
                    "which allows you to then spend your Italocoin safely.<br>" +
                    "If you do not use a key-reusing Italocoin clone without these safety features, then you do not need to do anything " +
                    "as it is all automated.<br>"
                )
                sharedRingDBDialog.icon = StandardIcon.Information
                sharedRingDBDialog.open()
            }
        }

        Text {
            textFormat: Text.RichText
            font.family: Style.fontRegular.name
            font.pixelSize: 14 * scaleRatio
            text: qsTr("This records rings used by outputs spent on Italocoin on a key reusing chain, so that the same ring may be reused to avoid privacy issues.") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true;
            color: Style.defaultFontColor
        }

        RowLayout {
            LineEdit {
                id: keyImageLine
                fontSize: mainLayout.lineEditFontSize
                labelFontSize: 14 * scaleRatio
                labelText: qsTr("Key image") + ":" + translationManager.emptyString
                placeholderText: qsTr("Paste key image") + "..." + translationManager.emptyString
                readOnly: false
                copyButton: true
                width: mainLayout.editWidth
                Layout.fillWidth: true
            }
        }

        GridLayout{
            Layout.topMargin: 12 * scaleRatio
            columns: (isMobile) ?  1 : 2
            columnSpacing: 32 * scaleRatio

            ColumnLayout {
                RowLayout {
                    LineEdit {
                        id: getRingLine
                        Layout.fillWidth: true
                        fontSize: mainLayout.lineEditFontSize
                        labelFontSize: 14 * scaleRatio
                        labelText: qsTr("Get ring") + ":" + translationManager.emptyString
                        readOnly: true
                        copyButton: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 18

                    StandardButton {
                        id: getRingButton
                        text: qsTr("Get Ring") + translationManager.emptyString
                        small: true
                        enabled: !!appWindow.currentWallet && validHex32(keyImageLine.text)
                        onClicked: {
                            var ring = appWindow.currentWallet.getRing(keyImageLine.text)
                            if (ring === "") {
                                getRingLine.text = qsTr("No ring found");
                            }
                            else {
                                getRingLine.text = ring;
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                RowLayout {
                    LineEdit {
                        id: setRingLine
                        Layout.fillWidth: true
                        fontSize: mainLayout.lineEditFontSize
                        labelFontSize: 14 * scaleRatio
                        labelText: qsTr("Set ring") + ":" + translationManager.emptyString
                        readOnly: false
                        copyButton: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 18

                    StandardButton {
                        id: setRingButton
                        text: qsTr("Set Ring") + translationManager.emptyString
                        small: true
                        enabled: !!appWindow.currentWallet && validHex32(keyImageLine.text) && validRing(setRingLine.text.trim(), setRingRelative.checked)
                        onClicked: {
                            var outs = setRingLine.text.trim()
                            appWindow.currentWallet.setRing(keyImageLine.text, outs, setRingRelative.checked)
                        }
                    }
                }
            }
        }

        GridLayout {
            columns: (isMobile) ?  1 : 2

            CheckBox {
                id: segregatePreForkOutputs
                checked: persistentSettings.segregatePreForkOutputs
                text: qsTr("I intend to spend on key-reusing fork(s)") + translationManager.emptyString
                checkedIcon: "../images/checkedIcon-black.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
                onClicked: {
                    persistentSettings.segregatePreForkOutputs = segregatePreForkOutputs.checked
                    if (appWindow.currentWallet) {
                        appWindow.currentWallet.segregatePreForkOutputs(segregatePreForkOutputs.checked)
                    }
                }
            }

            CheckBox {
                id: keyReuseMitigation2
                checked: persistentSettings.keyReuseMitigation2
                text: qsTr("I might want to spend on key-reusing fork(s)") + translationManager.emptyString
                checkedIcon: "../images/checkedIcon-black.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
                onClicked: {
                    persistentSettings.keyReuseMitigation2 = keyReuseMitigation2.checked
                    if (appWindow.currentWallet) {
                        appWindow.currentWallet.keyReuseMitigation2(keyReuseMitigation2.checked)
                    }
                }
            }

            CheckBox {
                id: setRingRelative
                checked: true
                text: qsTr("Relative") + translationManager.emptyString
                checkedIcon: "../images/checkedIcon-black.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
            }
        }

        RowLayout {
            id: segregationHeightRow
            anchors.topMargin: 17
            anchors.left: parent.left
            anchors.right: parent.right

            LineEdit {
                id: segregationHeightLine
                readOnly: false
                labelFontSize: 14 * scaleRatio
                labelText: qsTr("Segregation height:") + translationManager.emptyString
                Layout.fillWidth: true
                validator: IntValidator { bottom: 0 }
                onEditingFinished: {
                    persistentSettings.segregationHeight = segregationHeightLine.text
                    if (appWindow.currentWallet) {
                        appWindow.currentWallet.segregationHeight(segregationHeightLine.text)
                    }
                }
            }
        }
    }

    function onPageCompleted() {
        console.log("RingDB page loaded");
        appWindow.currentWallet.segregatePreForkOutputs(persistentSettings.segregatePreForkOutputs)
        appWindow.currentWallet.segregationHeight(persistentSettings.segregationHeight)
        segregationHeightLine.text = persistentSettings.segregationHeight
        appWindow.currentWallet.keyReuseMitigation2(persistentSettings.keyReuseMitigation2)
    }
}