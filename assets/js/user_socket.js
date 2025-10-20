// Socket Phoenix pour les communications temps réel
// Utilisé pour WebRTC signaling et chat

import {Socket} from "phoenix"

// Créer le socket
let socket = new Socket("/socket", {
  params: {token: window.userToken},
  logger: (kind, msg, data) => {
    console.log(`${kind}: ${msg}`, data)
  }
})

// Connecter le socket
socket.connect()

// Exposer globalement pour utilisation dans d'autres modules
window.PhoenixSocket = socket

// Canal vidéo d'exemple (désactivé par défaut)
// let channel = socket.channel("video:lobby", {})
// channel.join()
//   .receive("ok", resp => { console.log("Joined successfully", resp) })
//   .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
