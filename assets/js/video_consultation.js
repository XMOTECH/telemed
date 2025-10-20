// Module de consultation vidéo avec WebRTC et Phoenix Channels
// Système de télémédecine - Consultation vidéo en temps réel

export class VideoConsultation {
  constructor(roomId, userName) {
    this.roomId = roomId;
    this.userName = userName;
    this.socket = null;
    this.channel = null;
    this.localStream = null;
    this.screenStream = null;
    this.peerConnections = {};
    this.isInitiator = false;
    this.audioEnabled = true;
    this.videoEnabled = true;
    this.isScreenSharing = false;
    
    // Configuration ICE servers (STUN/TURN) - Améliorée pour ngrok
    this.configuration = {
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' },
        { urls: 'stun:stun1.l.google.com:19302' },
        { urls: 'stun:stun2.l.google.com:19302' },
        { urls: 'stun:stun3.l.google.com:19302' },
        { urls: 'stun:stun4.l.google.com:19302' },
        { urls: 'stun:stun.ekiga.net' },
        { urls: 'stun:stun.ideasip.com' },
        { urls: 'stun:stun.schlund.de' },
        { urls: 'stun:stun.stunprotocol.org:3478' },
        { urls: 'stun:stun.voiparound.com' },
        { urls: 'stun:stun.voipbuster.com' },
        { urls: 'stun:stun.voipstunt.com' },
        { urls: 'stun:stun.counterpath.com' },
        { urls: 'stun:stun.1und1.de' }
      ],
      iceCandidatePoolSize: 10,
      iceTransportPolicy: 'all',
      bundlePolicy: 'max-bundle',
      rtcpMuxPolicy: 'require'
    };

    // Callbacks personnalisables
    this.onLocalStream = null;
    this.onRemoteStream = null;
    this.onRemoteStreamRemoved = null;
    this.onChatMessage = null;
    this.onUserJoined = null;
    this.onUserLeft = null;
    this.onStatusChange = null;
    this.onError = null;
  }

  // === CONNEXION ET INITIALISATION ===

  async connect() {
    try {
      this.updateStatus("Connexion au serveur...");
      
      // Créer et connecter le socket Phoenix
      if (typeof Phoenix === 'undefined') {
        throw new Error("Phoenix n'est pas chargé");
      }

      this.socket = new Phoenix.Socket("/socket", {
        params: { user_name: this.userName }
      });
      
      this.socket.connect();
      
      // Rejoindre le channel de la salle
      this.channel = this.socket.channel(`video:${this.roomId}`, {
        user_name: this.userName
      });

      // Configurer les listeners
      this.setupChannelListeners();

      // Rejoindre la salle
      const response = await new Promise((resolve, reject) => {
        this.channel.join()
          .receive("ok", resp => resolve(resp))
          .receive("error", resp => reject(resp));
      });

      this.userId = response.user_id;
      this.updateStatus(`Connecté à la salle ${this.roomId}`);
      
      console.log("Connexion établie:", response);
      return response;
      
    } catch (error) {
      this.handleError("Erreur de connexion", error);
      throw error;
    }
  }

  setupChannelListeners() {
    // Nouvel utilisateur rejoint
    this.channel.on("user_joined", (payload) => {
      console.log("Utilisateur rejoint:", payload);
      this.updateStatus(`${payload.user_name} a rejoint la consultation`);
      
      if (this.onUserJoined) {
        this.onUserJoined(payload);
      }
      
      // Si on a déjà un stream, créer une connexion peer
      if (this.localStream) {
        this.createPeerConnection(payload.user_id);
      }
    });

    // Utilisateur quitte
    this.channel.on("user_left", (payload) => {
      console.log("Utilisateur parti:", payload);
      this.updateStatus(`${payload.user_name} a quitté la consultation`);
      
      if (this.onUserLeft) {
        this.onUserLeft(payload);
      }
      
      // Fermer la connexion peer
      this.closePeerConnection(payload.user_id);
    });

    // Offre WebRTC reçue
    this.channel.on("offer", async (payload) => {
      console.log("Offre reçue de:", payload.from_name);
      
      if (payload.to && payload.to !== this.userId) {
        return; // Pas pour nous
      }
      
      await this.handleOffer(payload);
    });

    // Réponse WebRTC reçue
    this.channel.on("answer", async (payload) => {
      console.log("Réponse reçue de:", payload.from_name);
      
      if (payload.to && payload.to !== this.userId) {
        return;
      }
      
      await this.handleAnswer(payload);
    });

    // Candidat ICE reçu
    this.channel.on("ice_candidate", async (payload) => {
      if (payload.to && payload.to !== this.userId) {
        return;
      }
      
      await this.handleIceCandidate(payload);
    });

    // Message de chat
    this.channel.on("chat_message", (payload) => {
      console.log("Message de chat:", payload);
      
      if (this.onChatMessage) {
        this.onChatMessage(payload);
      }
    });

    // Changements audio/vidéo
    this.channel.on("user_audio_changed", (payload) => {
      console.log("Audio changé:", payload);
      // Mettre à jour l'UI
    });

    this.channel.on("user_video_changed", (payload) => {
      console.log("Vidéo changée:", payload);
      // Mettre à jour l'UI
    });

    // Partage d'écran
    this.channel.on("user_screen_share_started", (payload) => {
      console.log("Partage d'écran démarré:", payload);
      this.updateStatus(`${payload.user_name} partage son écran`);
    });

    this.channel.on("user_screen_share_stopped", (payload) => {
      console.log("Partage d'écran arrêté:", payload);
    });
  }

  // === GESTION DU STREAM LOCAL ===

  async startLocalStream(videoConstraints = true, audioConstraints = true) {
    try {
      this.updateStatus("Activation de la caméra et du microphone...");
      
      const constraints = {
        video: videoConstraints,
        audio: audioConstraints
      };

      this.localStream = await navigator.mediaDevices.getUserMedia(constraints);
      
      this.audioEnabled = audioConstraints !== false;
      this.videoEnabled = videoConstraints !== false;
      
      this.updateStatus("Caméra et microphone activés");
      
      if (this.onLocalStream) {
        this.onLocalStream(this.localStream);
      }
      
      return this.localStream;
      
    } catch (error) {
      this.handleError("Erreur d'accès aux médias", error);
      throw error;
    }
  }

  stopLocalStream() {
    if (this.localStream) {
      this.localStream.getTracks().forEach(track => track.stop());
      this.localStream = null;
      this.updateStatus("Caméra et microphone désactivés");
    }
  }

  // === GESTION WEBRTC ===

  createPeerConnection(remoteUserId) {
    console.log("Création connexion peer pour:", remoteUserId);
    
    const pc = new RTCPeerConnection(this.configuration);
    this.peerConnections[remoteUserId] = pc;

    // Ajouter les tracks locaux
    if (this.localStream) {
      this.localStream.getTracks().forEach(track => {
        pc.addTrack(track, this.localStream);
        console.log("Track ajouté:", track.kind);
      });
    }

    // Gérer les candidats ICE - Amélioré pour ngrok
    pc.onicecandidate = (event) => {
      if (event.candidate) {
        console.log("✅ Candidat ICE trouvé:", event.candidate.type, event.candidate.protocol);
        this.channel.push("ice_candidate", {
          candidate: event.candidate,
          to: remoteUserId
        });
      } else {
        console.log("❌ Fin des candidats ICE");
      }
    };

    // Gestion des états de connexion - Debug amélioré
    pc.onconnectionstatechange = () => {
      console.log("🔄 État connexion:", pc.connectionState);
      if (pc.connectionState === 'connected') {
        console.log("✅ CONNEXION ÉTABLIE avec", remoteUserId);
      } else if (pc.connectionState === 'failed') {
        console.log("❌ ÉCHEC CONNEXION avec", remoteUserId);
      }
    };

    pc.oniceconnectionstatechange = () => {
      console.log("🧊 État ICE:", pc.iceConnectionState);
    };

    // Gérer le stream distant - Amélioré pour ngrok
    pc.ontrack = (event) => {
      console.log("🎥 Track distant reçu:", event.track.kind, "de", remoteUserId);
      
      if (event.streams && event.streams[0]) {
        console.log("✅ Stream distant validé");
        if (this.onRemoteStream) {
          this.onRemoteStream(event.streams[0], remoteUserId);
        }
      } else {
        console.log("⚠️ Stream distant invalide");
      }
    };

    // Gestion des changements de connexion - Consolidée
    pc.onconnectionstatechange = () => {
      console.log("🔄 État connexion:", pc.connectionState);
      
      switch (pc.connectionState) {
        case 'connected':
          console.log("✅ CONNEXION VIDÉO ÉTABLIE avec", remoteUserId);
          this.updateStatus("Connexion vidéo établie");
          break;
        case 'disconnected':
          console.log("⚠️ CONNEXION INTERROMPUE avec", remoteUserId);
          this.updateStatus("Connexion interrompue");
          break;
        case 'failed':
          console.log("❌ ÉCHEC CONNEXION avec", remoteUserId);
          this.updateStatus("Échec de la connexion");
          this.closePeerConnection(remoteUserId);
          break;
        case 'connecting':
          console.log("🔄 CONNEXION EN COURS avec", remoteUserId);
          this.updateStatus("Connexion en cours...");
          break;
      }
    };

    // Créer l'offre si on est l'initiateur
    this.createOffer(remoteUserId);
  }

  async createOffer(remoteUserId) {
    const pc = this.peerConnections[remoteUserId];
    
    if (!pc) {
      console.error("❌ Pas de peer connection pour:", remoteUserId);
      return;
    }

    try {
      console.log("📤 Création offre WebRTC pour:", remoteUserId);
      
      const offer = await pc.createOffer({
        offerToReceiveAudio: true,
        offerToReceiveVideo: true,
        voiceActivityDetection: true,
        iceRestart: false
      });
      
      await pc.setLocalDescription(offer);
      console.log("✅ Description locale définie");
      
      console.log("📤 Envoi offre à:", remoteUserId);
      this.channel.push("offer", {
        offer: offer,
        to: remoteUserId
      });
      
    } catch (error) {
      console.error("❌ Erreur création offre:", error);
      this.handleError("Erreur création offre", error);
    }
  }

  async handleOffer(payload) {
    const { offer, from } = payload;
    
    console.log("📥 Réception offre de:", from);
    
    // Créer une connexion peer si elle n'existe pas
    if (!this.peerConnections[from]) {
      this.createPeerConnection(from);
    }
    
    const pc = this.peerConnections[from];
    
    try {
      await pc.setRemoteDescription(new RTCSessionDescription(offer));
      console.log("✅ Description distante définie");
      
      const answer = await pc.createAnswer({
        voiceActivityDetection: true
      });
      await pc.setLocalDescription(answer);
      console.log("✅ Description locale définie");
      
      console.log("📤 Envoi réponse à:", from);
      this.channel.push("answer", {
        answer: answer,
        to: from
      });
      
    } catch (error) {
      this.handleError("Erreur traitement offre", error);
    }
  }

  async handleAnswer(payload) {
    const { answer, from } = payload;
    const pc = this.peerConnections[from];
    
    if (!pc) {
      console.error("❌ Pas de peer connection pour:", from);
      return;
    }
    
    try {
      console.log("📥 Réception réponse de:", from);
      await pc.setRemoteDescription(new RTCSessionDescription(answer));
      console.log("✅ Réponse appliquée de:", from);
      
    } catch (error) {
      console.error("❌ Erreur traitement réponse:", error);
      this.handleError("Erreur traitement réponse", error);
    }
  }

  async handleIceCandidate(payload) {
    const { candidate, from } = payload;
    const pc = this.peerConnections[from];
    
    if (!pc) {
      console.error("❌ Pas de peer connection pour:", from);
      return;
    }
    
    try {
      console.log("🧊 Ajout candidat ICE de:", from, candidate.type);
      await pc.addIceCandidate(new RTCIceCandidate(candidate));
      console.log("Candidat ICE ajouté de:", from);
      
    } catch (error) {
      this.handleError("Erreur ajout candidat ICE", error);
    }
  }

  closePeerConnection(remoteUserId) {
    const pc = this.peerConnections[remoteUserId];
    
    if (pc) {
      pc.close();
      delete this.peerConnections[remoteUserId];
      
      if (this.onRemoteStreamRemoved) {
        this.onRemoteStreamRemoved(remoteUserId);
      }
    }
  }

  // === CONTRÔLES AUDIO/VIDÉO ===

  toggleAudio() {
    if (!this.localStream) return false;
    
    this.audioEnabled = !this.audioEnabled;
    
    this.localStream.getAudioTracks().forEach(track => {
      track.enabled = this.audioEnabled;
    });
    
    this.channel.push("toggle_audio", { enabled: this.audioEnabled });
    this.updateStatus(this.audioEnabled ? "Micro activé" : "Micro désactivé");
    
    return this.audioEnabled;
  }

  toggleVideo() {
    if (!this.localStream) return false;
    
    this.videoEnabled = !this.videoEnabled;
    
    this.localStream.getVideoTracks().forEach(track => {
      track.enabled = this.videoEnabled;
    });
    
    this.channel.push("toggle_video", { enabled: this.videoEnabled });
    this.updateStatus(this.videoEnabled ? "Caméra activée" : "Caméra désactivée");
    
    return this.videoEnabled;
  }

  // === PARTAGE D'ÉCRAN ===

  async startScreenShare() {
    try {
      this.screenStream = await navigator.mediaDevices.getDisplayMedia({
        video: {
          cursor: "always"
        },
        audio: false
      });
      
      // Remplacer le track vidéo dans toutes les connexions
      const videoTrack = this.screenStream.getVideoTracks()[0];
      
      Object.values(this.peerConnections).forEach(pc => {
        const sender = pc.getSenders().find(s => s.track && s.track.kind === 'video');
        if (sender) {
          sender.replaceTrack(videoTrack);
        }
      });
      
      // Détecter l'arrêt du partage
      videoTrack.onended = () => {
        this.stopScreenShare();
      };
      
      this.isScreenSharing = true;
      this.channel.push("start_screen_share", {});
      this.updateStatus("Partage d'écran démarré");
      
      return this.screenStream;
      
    } catch (error) {
      this.handleError("Erreur partage d'écran", error);
      throw error;
    }
  }

  stopScreenShare() {
    if (this.screenStream) {
      this.screenStream.getTracks().forEach(track => track.stop());
      this.screenStream = null;
    }
    
    // Remettre le track vidéo de la caméra
    if (this.localStream) {
      const videoTrack = this.localStream.getVideoTracks()[0];
      
      Object.values(this.peerConnections).forEach(pc => {
        const sender = pc.getSenders().find(s => s.track && s.track.kind === 'video');
        if (sender && videoTrack) {
          sender.replaceTrack(videoTrack);
        }
      });
    }
    
    this.isScreenSharing = false;
    this.channel.push("stop_screen_share", {});
    this.updateStatus("Partage d'écran arrêté");
  }

  // === CHAT ===

  sendChatMessage(message) {
    if (!message.trim()) return;
    
    this.channel.push("chat_message", { message: message });
  }

  // === UTILITAIRES ===

  updateStatus(message) {
    console.log("Status:", message);
    if (this.onStatusChange) {
      this.onStatusChange(message);
    }
  }

  handleError(context, error) {
    console.error(context, error);
    
    if (this.onError) {
      this.onError(context, error);
    }
  }

  // === DÉCONNEXION ===

  disconnect() {
    // Arrêter tous les streams
    this.stopLocalStream();
    this.stopScreenShare();
    
    // Fermer toutes les connexions peers
    Object.keys(this.peerConnections).forEach(userId => {
      this.closePeerConnection(userId);
    });
    
    // Quitter le channel
    if (this.channel) {
      this.channel.leave();
      this.channel = null;
    }
    
    // Déconnecter le socket
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
    
    this.updateStatus("Déconnecté");
  }

  // === VÉRIFICATIONS ===

  static checkWebRTCSupport() {
    const checks = {
      mediaDevices: !!navigator.mediaDevices,
      getUserMedia: !!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia),
      RTCPeerConnection: !!(window.RTCPeerConnection),
      getDisplayMedia: !!(navigator.mediaDevices && navigator.mediaDevices.getDisplayMedia)
    };
    
    checks.supported = checks.mediaDevices && checks.getUserMedia && checks.RTCPeerConnection;
    
    return checks;
  }
}

// Export par défaut
export default VideoConsultation;

