import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 800
    height: 600

    property string currentView: "forums"
    property var forumsModel: []
    property var postsModel: []
    property var strikesModel: []
    property string statusMessage: ""

    // Forum parameters
    property int kStrikes: 3
    property int nThreshold: 2
    property int mModerators: 3

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "#1a1a2e"
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12

                Text {
                    text: "Anonymous Forum"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#e94560"
                }

                Item { Layout.fillWidth: true }

                Row {
                    spacing: 8

                    Button {
                        text: "Forums"
                        highlighted: currentView === "forums"
                        onClicked: currentView = "forums"
                    }
                    Button {
                        text: "Post"
                        highlighted: currentView === "post"
                        onClicked: currentView = "post"
                    }
                    Button {
                        text: "Moderate"
                        highlighted: currentView === "moderate"
                        onClicked: currentView = "moderate"
                    }
                }
            }
        }

        // Status bar
        Rectangle {
            Layout.fillWidth: true
            height: statusMessage.length > 0 ? 40 : 0
            color: "#2e7d32"
            radius: 4
            visible: statusMessage.length > 0

            TextEdit {
                anchors.fill: parent
                anchors.margins: 8
                text: statusMessage
                color: "#ffffff"
                font.pixelSize: 12
                readOnly: true
                selectByMouse: true
                wrapMode: TextEdit.Wrap
                verticalAlignment: TextEdit.AlignVCenter
            }
        }

        // Content area
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: currentView === "forums" ? 0 : currentView === "post" ? 1 : 2

            // --- Forums View ---
            ColumnLayout {
                spacing: 12

                Text {
                    text: "Forum Instances"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#e94560"
                }

                // Create forum controls
                GroupBox {
                    Layout.fillWidth: true
                    title: "Register as Member"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        RowLayout {
                            Label { text: "NSK (hex):" }
                            TextField {
                                id: nskInput
                                Layout.fillWidth: true
                                placeholderText: "32-byte secret key in hex (64 chars)"
                            }
                        }

                        RowLayout {
                            Label { text: "K-Strikes:" }
                            SpinBox { id: kInput; from: 1; to: 10; value: 3 }
                            Label { text: "N-of-M:" }
                            SpinBox { id: nInput; from: 1; to: 10; value: 2 }
                            Label { text: "of" }
                            SpinBox { id: mInput; from: 1; to: 10; value: 3 }
                        }

                        Button {
                            text: "Register Member"
                            onClicked: {
                                var result = logos.callModule("anonymous_forum_core",
                                    "createMember", [nskInput.text, kInput.value])
                                statusMessage = "Register: " + result
                            }
                        }
                    }
                }

                // Moderator pubkeys input
                GroupBox {
                    Layout.fillWidth: true
                    title: "Moderator Setup"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        TextArea {
                            id: modPubkeysInput
                            Layout.fillWidth: true
                            placeholderText: 'JSON array of moderator pubkey hex strings\ne.g. ["aabb...","ccdd...","eeff..."]'
                            wrapMode: TextArea.Wrap
                        }

                        Button {
                            text: "Create Aggregator"
                            onClicked: {
                                var result = logos.callModule("anonymous_forum_core",
                                    "createAggregator",
                                    [nInput.value, kInput.value, modPubkeysInput.text])
                                statusMessage = "Aggregator: " + result
                            }
                        }
                    }
                }
            }

            // --- Post View ---
            ColumnLayout {
                spacing: 12

                Text {
                    text: "Create Anonymous Post"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#e94560"
                }

                GroupBox {
                    Layout.fillWidth: true
                    title: "New Post"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        TextArea {
                            id: messageInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            placeholderText: "Your anonymous message..."
                            wrapMode: TextArea.Wrap
                        }

                        TextField {
                            id: saltInput
                            Layout.fillWidth: true
                            placeholderText: "Post salt (hex, 64 chars) — unique per post"
                        }

                        Button {
                            text: "Publish Anonymously"
                            onClicked: {
                                var result = logos.callModule("anonymous_forum_core",
                                    "preparePost",
                                    [messageInput.text, saltInput.text,
                                     modPubkeysInput.text, nInput.value])
                                statusMessage = "Post result: " + result.substring(0, 100) + "..."
                                postResultArea.text = result
                            }
                        }

                        TextArea {
                            id: postResultArea
                            Layout.fillWidth: true
                            Layout.preferredHeight: 150
                            readOnly: true
                            placeholderText: "Post payload will appear here (JSON)"
                            wrapMode: TextArea.Wrap
                            font.family: "monospace"
                            font.pixelSize: 11
                        }
                    }
                }
            }

            // --- Moderate View ---
            ColumnLayout {
                spacing: 12

                Text {
                    text: "Moderation Dashboard"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#e94560"
                }

                GroupBox {
                    Layout.fillWidth: true
                    title: "Moderator Login"

                    RowLayout {
                        anchors.fill: parent

                        TextField {
                            id: modPrivkeyInput
                            Layout.fillWidth: true
                            placeholderText: "Moderator private key (hex)"
                        }

                        Button {
                            text: "Login"
                            onClicked: {
                                var result = logos.callModule("anonymous_forum_core",
                                    "createModerator", [modPrivkeyInput.text])
                                var pk = logos.callModule("anonymous_forum_core",
                                    "getModeratorPubkey", [])
                                statusMessage = "Moderator pubkey: " + pk
                            }
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true
                    title: "Issue Strike"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        TextField {
                            id: strikeTagInput
                            Layout.fillWidth: true
                            placeholderText: "Tracing tag (hex)"
                        }

                        TextArea {
                            id: strikeShareInput
                            Layout.fillWidth: true
                            placeholderText: "Encrypted share (JSON)"
                            wrapMode: TextArea.Wrap
                        }

                        SpinBox {
                            id: modIndexInput
                            from: 0; to: 9
                        }

                        Button {
                            text: "Issue Strike"
                            onClicked: {
                                var result = logos.callModule("anonymous_forum_core",
                                    "issueStrike",
                                    [strikeTagInput.text, strikeShareInput.text,
                                     modIndexInput.value])
                                strikeResultArea.text = result
                                statusMessage = "Strike issued"
                            }
                        }

                        TextArea {
                            id: strikeResultArea
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            readOnly: true
                            placeholderText: "Strike certificate (JSON)"
                            wrapMode: TextArea.Wrap
                            font.family: "monospace"
                            font.pixelSize: 11
                        }
                    }
                }

                GroupBox {
                    Layout.fillWidth: true
                    title: "Reconstruct & Slash"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        TextArea {
                            id: certsInput
                            Layout.fillWidth: true
                            placeholderText: "Certificates JSON (for reconstruct_strike)"
                            wrapMode: TextArea.Wrap
                        }

                        Button {
                            text: "Reconstruct Strike (Tier 1)"
                            onClicked: {
                                var result = logos.callModule("anonymous_forum_core",
                                    "reconstructStrike",
                                    [strikeTagInput.text, certsInput.text])
                                slashResultArea.text = result
                                statusMessage = "Tier 1 reconstruct: " + result
                            }
                        }

                        TextArea {
                            id: accStrikesInput
                            Layout.fillWidth: true
                            placeholderText: 'Accumulated strikes JSON\ne.g. [[1,"hexS1"],[2,"hexS2"],[3,"hexS3"]]'
                            wrapMode: TextArea.Wrap
                        }

                        Button {
                            text: "Reconstruct NSK (Tier 2 — Slash)"
                            onClicked: {
                                var result = logos.callModule("anonymous_forum_core",
                                    "reconstructNsk", [accStrikesInput.text])
                                slashResultArea.text = result
                                statusMessage = "NSK reconstructed — member can be slashed"
                            }
                        }

                        TextArea {
                            id: slashResultArea
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            readOnly: true
                            placeholderText: "Result"
                            wrapMode: TextArea.Wrap
                            font.family: "monospace"
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}
