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

import {socket, socket2, socket3} from "./socket"


// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {});
let channel2 = socket2.channel("room:lobby2", {});
let channel3 = socket3.channel("room:lobby3", {});

let my_id = null;

let cameraX = 0.0;
let cameraY = 0.0;
let cameraTargetX = 0.0;
let cameraTargetY = 0.0;
let cameraScale = 10.0;
let names = {};
let time = 0.0;

channel2.join()
    .receive("ok", resp => { console.log("Channel 2 joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join channel 2", resp) });

channel3.join()
    .receive("ok", resp => { console.log("Channel 3 joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join channel 3", resp) });

channel.join()
  .receive("ok", resp => {
      console.log("Joined successfully. ID: ", resp);
      my_id = resp;
      document.getElementById('display-name').addEventListener('keyup', function(e) {
          channel.push('set_name', {name: e.target.value})
      });
      document.addEventListener('keydown', function(e) {
          console.log(e.key);
          switch (e.key) {
              case 'ArrowUp':
                e.preventDefault();
                return channel.push('move', { action: 'thrust' });
              case 'ArrowDown':
                e.preventDefault();
                return channel.push('move', { action: 'reverse' });
              case 'ArrowLeft':
                e.preventDefault();
                return channel.push('move', { action: 'ccw' });
              case 'ArrowRight':
                e.preventDefault();
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

const ipAddr = document.getElementById("ip-addr");
if (ipAddr) {
    ipAddr.innerText = window.location;
}

channel.on("names", resp => {
    console.log("received names", resp);
    names = resp;
});

const onUpdate = resp => {
    if (resp.time < time) {
        console.log("dropping frame");
        return;
    }

    time = resp.time;
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
        ctx.fillStyle = (data.id === my_id) ? "#00f" : "#444";
        let name = names[data.id];
        if (name) {
            console.log(name);
            ctx.font = '48px';
            ctx.fillText(name, 20, 0);
        }

        ctx.rotate(-data.r);
        ctx.fillStyle = (data.id === my_id) ? "#00f" : "#aaa";
        ctx.fillRect(-1 * cameraScale, -1 * cameraScale, 2 * cameraScale, 2 * cameraScale);
        ctx.strokeRect(-1 * cameraScale, -1 * cameraScale, 2 * cameraScale, 2 * cameraScale);

        // ctx.fillRect(-2, -2, 4, 4);
        // ctx.strokeRect(-2, -2, 4, 4);
    })
};

channel.on("update", onUpdate);
channel2.on("update", onUpdate);
channel3.on("update", onUpdate);

function worldToCanvasCoords(v) {
    let cX = cameraScale > 1.0 ? cameraX : 0.0;
    let cY = cameraScale > 1.0 ? cameraY : 0.0;
    return {
        x: ((v.x - cX) * cameraScale) + canvas.width / 2,
        y: ((-v.y + cY) * cameraScale) + canvas.height / 2,
    };
}
