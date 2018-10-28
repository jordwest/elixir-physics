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

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp); my_id = resp })
  .receive("error", resp => { console.log("Unable to join", resp) })

const canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");

channel.on("update", resp => {
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    resp.bodies.forEach(data => {
        const coords = worldToCanvasCoords(data);

        ctx.setTransform(1, 0, 0, 1, 0, 0);

        ctx.translate(coords.x, coords.y);
        ctx.rotate(data.r);
        ctx.fillStyle = (data.id === my_id) ? "#00f" : "#aaa";
        ctx.fillRect(-20, -20, 40, 40);
        ctx.strokeRect(-20, -20, 40, 40);
    })
});

function worldToCanvasCoords(v) {
    return { x: (v.x) + 300, y: (-v.y) + 200 }
}
