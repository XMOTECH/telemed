let localVideo = document.getElementById("localVideo");
let startCall = document.getElementById("startCall");

startCall.onclick = async () => {
  let localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
  localVideo.srcObject = localStream;
};
