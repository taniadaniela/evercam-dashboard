import {Socket} from "phoenix"

let recording_cameras = [
  "beefcam1",
  "beefcam2",
  "beefcammobile",
  "bennett",
  "carrollszoocam",
  "centralbankbuild",
  "dancecam",
  "dcctestdumpinghk",
  "gemcon-cathalbrugha",
  "gpocam",
  "smartcity1",
  "stephens-green",
  "treacyconsulting1",
  "treacyconsulting2",
  "treacyconsulting3",
  "wayra-agora",
  "wayra_office",
  "wayrahikvision",
  "zipyard-navan-foh",
  "zipyard-ranelagh-foh"
]

$(() => {
  let camera_id = window.Evercam.Camera.id;

  let socket = new Socket("wss://media.evercam.io/ws")

  socket.connect();

  let chan = socket.chan(`cameras:${camera_id}`, {})

  chan.join().receive("ok", ({messages}) => {
    if ($.inArray(camera_id, recording_cameras) !== -1) {
      window.snapshot_streaming_enabled = true;
    }
  })

  chan.on("snapshot-taken", payload => {
    $("#live-player-image").attr("src", "data:image/jpeg;base64," + payload.image);
  })
})
