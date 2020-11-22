 /*  Copyright https://github.com/Furkanzmc/QML-Loaders
 *   Copyright Alexey Varfolomeev https://github.com/varlesh/prof-kde
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 3,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.7
import QtQuick.Window 2.2

Item {

    // ----- Public Properties ----- //

    property int radius: 50
    property bool useDouble: false
    property bool running: true

    property color color: "#ffffff"

    // ----- Private Properties ----- //

    property int _innerRadius: radius * 0.7
    property int _circleRadius: (radius - _innerRadius) * 0.5

    Image {
            id: wallpaper
            anchors.centerIn: parent
            source: "images/KDE Glitch.png"
            sourceSize.height: size
            sourceSize.width: size
    }
    
    Rectangle {
    id: label
    anchors.centerIn: parent
    

    property int stage

    onStageChanged: {
        if (stage == 2) {
            introAnimation.running = true;
        }
    }

        Image {
            id: logo
            anchors.centerIn: parent
            source: "images/logo.svg"
            sourceSize.width: size
            sourceSize.height: size
        }
        
    }

    OpacityAnimator {
        id: introAnimation
        running: true
        target: label
        from: 0
        to: 1
        duration: 4000
        easing.type: Easing.InOutQuad
    }

        
    id: root
    width: radius * 2
    height: radius * 2
    onRunningChanged: {
        if (running === false) {
            for (var i = 0; i < repeater.model; i++) {
                if (repeater.itemAt(i)) {
                    repeater.itemAt(i).stopAnimation();
                }
            }
        }
        else {
            for (var i = 0; i < repeater.model; i++) {
                if (repeater.itemAt(i)) {
                    repeater.itemAt(i).playAnimation();
                }
            }
        }
    }

    Repeater {
        id: repeater
        model: root.useDouble ? 6 : 6
        delegate: Component {
            Rectangle {
                // ----- Private Properties ----- //
                property int _currentAngle: _getStartAngle()

                id: rect
                width: _getWidth()
                height: width
                radius: width
                color: root.color
                transformOrigin: Item.Center
                y: root._getPosOnCircle(_currentAngle).x
                x: root._getPosOnCircle(_currentAngle).y
                antialiasing: true

                SequentialAnimation {
                    id: anim
                    loops: Animation.Infinite

                    NumberAnimation {
                        target: rect
                        property: "_currentAngle"
                        duration: root.useDouble ? 800 : 1400
                        from: rect._getStartAngle()
                        to: 360 + rect._getStartAngle()
                        easing.type: Easing.OutQuad
                    }

                    PauseAnimation { duration: 200 }
                }

                // ----- Public Functions ----- //

                function playAnimation() {
                    if (anim.running == false) {
                        anim.start();
                    }
                    else if (anim.paused) {
                        anim.resume();
                    }
                }

                function stopAnimation() {
                    if (anim.running) {
                        anim.pause();
                    }
                }

                // ----- Private Functions ----- //

                function _getStartAngle() {
                    var ang = 90;
                    if (root.useDouble) {
                        ang = index < 5 ? 90 : 270;
                    }

                    return ang;
                }

                function _getWidth() {
                    var w = (root._circleRadius) * 0.5 * (repeater.model - index);
                    if (root.useDouble) {
                        w = (root._circleRadius) * 0.5 * ((repeater.model / 2) - Math.abs(repeater.model / 2 - index))
                    }

                    return w;
                }
            }
        }
    }

    Timer {
        // ----- Private Properties ----- //
        property int _circleIndex: 0

        id: timer
        interval: 200
        repeat: true
        running: true
        onTriggered: {
            var maxIndex = root.useDouble ? repeater.model / 2 : repeater.model;
            if (_circleIndex === maxIndex) {
                stop();
                _circleIndex = 0;
            }
            else {
                repeater.itemAt(_circleIndex).playAnimation();
                if (root.useDouble) {
                    repeater.itemAt(repeater.model - _circleIndex - 1).playAnimation();
                }

                _circleIndex++;
            }
        }
    }

    // ----- Private Functions ----- //

    function _toRadian(degree) {
        return (degree * 3.14159265) / 180.0;
    }

    function _getPosOnCircle(angleInDegree) {
        var centerX = root.height / 2, centerY = root.width / 2;
        var posX = 0, posY = 0;

        posX = centerX + root._innerRadius * Math.cos(_toRadian(angleInDegree));
        posY = centerY - root._innerRadius * Math.sin(_toRadian(angleInDegree));
        return Qt.point(posX, posY);
    }
}

