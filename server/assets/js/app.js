// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"


// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {})

let my_id = null;


let cameraX = 0.0;
let cameraY = 0.0;
let cameraTargetX = 0.0;
let cameraTargetY = 0.0;
let cameraScale = 10.0;

channel.join()
  .receive("ok", resp => {
      console.log("Joined successfully. ID: ", resp);
      my_id = resp;
      document.addEventListener('keydown', function(e) {
          console.log(e.key);
          switch (e.key) {
              case 'ArrowUp':
                return channel.push('move', { action: 'thrust' });
              case 'ArrowDown':
                return channel.push('move', { action: 'reverse' });
              case 'ArrowLeft':
                return channel.push('move', { action: 'ccw' });
              case 'ArrowRight':
                return channel.push('move', { action: 'cw' });
              case "=":
                if (cameraScale < 10.0) {
                    cameraScale *= 1.2;
                }
                return;
              case "-":
                if(cameraScale > 1.0) {
                    cameraScale *= 0.8;
                }else{
                    cameraScale = 1.0;
                }
                return;
          }
      })
    })
  .receive("error", resp => { console.log("Unable to join", resp) })

const canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");

channel.on("update", resp => {
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    cameraX = cameraX + ((cameraTargetX - cameraX) * 0.2);
    cameraY = cameraY + ((cameraTargetY - cameraY) * 0.2);

    const ctr = worldToCanvasCoords({x: 0.0, y: 0.0});

    [200.0, 150.0, 100.0, 80.0, 60.0, 40.0, 20.0, 10.0].forEach((r, i) => {
        ctx.beginPath();
        ctx.arc(ctr.x, ctr.y, r * cameraScale, 0, 2 * Math.PI);
        ctx.fillStyle = i % 2 === 0 ? "#ccc" : "#ddd";
        ctx.fill();
    })

    const floorPos = worldToCanvasCoords({x: -300, y: -10.0});
    ctx.fillStyle = "#000";
    ctx.fillRect(floorPos.x, floorPos.y, 600 * cameraScale, -10.0 * cameraScale);

    resp.bodies.forEach(data => {
        const coords = worldToCanvasCoords(data);

        ctx.setTransform(1, 0, 0, 1, 0, 0);

        if (data.id === my_id) {
            cameraTargetX = data.x;
            cameraTargetY = data.y;
        }
        ctx.translate(coords.x, coords.y);
        ctx.rotate(-data.r);
        ctx.fillStyle = (data.id === my_id) ? "#00f" : "#aaa";
        ctx.fillRect(-1 * cameraScale, -1 * cameraScale, 2 * cameraScale, 2 * cameraScale);
        ctx.strokeRect(-1 * cameraScale, -1 * cameraScale, 2 * cameraScale, 2 * cameraScale);
        // ctx.fillRect(-2, -2, 4, 4);
        // ctx.strokeRect(-2, -2, 4, 4);
    })
});

function worldToCanvasCoords(v) {
    let cX = cameraScale > 1.0 ? cameraX : 0.0;
    let cY = cameraScale > 1.0 ? cameraY : 0.0;
    return {
        x: ((v.x - cX) * cameraScale) + canvas.width / 2,
        y: ((-v.y + cY) * cameraScale) + canvas.height / 2,
        // x: (((v.x - cameraX) + (canvas.width)) * cameraScale) - canvas.width / 2,
        // y: (((-v.y + cameraY) + (canvas.height)) * cameraScale) - canvas.height / 2
    }
}
