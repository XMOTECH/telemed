/**
 * Module Chat Riche v2 pour Consultation Vidéo
 * Features : Markdown, Emojis, Réactions, Drag & Drop
 */

export class RichChat {
  constructor(channel) {
    this.channel = channel;
    this.messagesContainer = document.getElementById('chatMessages');
    this.input = document.getElementById('chatInput');
    this.form = document.getElementById('chatForm');
    this.emojiPickerOpen = false;
    
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Soumission formulaire
    this.form.addEventListener('submit', (e) => {
      e.preventDefault();
      this.sendMessage();
    });

    // Drag & Drop pour fichiers
    this.setupDragAndDrop();

    // Raccourcis clavier
    this.input.addEventListener('keydown', (e) => {
      // Ctrl/Cmd + Enter pour envoyer
      if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
        this.sendMessage();
      }
    });
  }

  sendMessage() {
    const message = this.input.value.trim();
    if (!message) return;

    // Parser le markdown simple
    const formattedMessage = this.parseMarkdown(message);

    this.channel.push('chat_message', { 
      message: message,
      formatted: formattedMessage,
      timestamp: new Date().toISOString()
    });

    this.input.value = '';
  }

  addMessage(data) {
    const isOwn = data.is_own || false;
    const messageDiv = document.createElement('div');
    messageDiv.className = `flex ${isOwn ? 'justify-end' : 'justify-start'} mb-3 group`;
    
    messageDiv.innerHTML = `
      <div class="flex items-end space-x-2 max-w-md">
        ${!isOwn ? this.renderAvatar(data.from_name) : ''}
        
        <div class="${isOwn ? 'bg-blue-600' : 'bg-gray-700'} rounded-lg px-4 py-2 shadow-md">
          <!-- Header -->
          <div class="flex items-center space-x-2 mb-1">
            <span class="text-xs font-semibold ${isOwn ? 'text-blue-200' : 'text-gray-300'}">
              ${data.from_name}
            </span>
            <span class="text-xs ${isOwn ? 'text-blue-300' : 'text-gray-500'}">
              ${this.formatTime(data.timestamp)}
            </span>
          </div>
          
          <!-- Message content -->
          <div class="text-white text-sm message-content">
            ${data.formatted || this.parseMarkdown(data.message)}
          </div>
          
          <!-- Réactions -->
          <div class="flex items-center space-x-2 mt-2 reactions" data-message-id="${data.id || Date.now()}">
            <!-- Les réactions seront ajoutées ici -->
          </div>
        </div>

        ${isOwn ? this.renderAvatar(data.from_name) : ''}
        
        <!-- Menu actions (au survol) -->
        <div class="opacity-0 group-hover:opacity-100 transition-opacity flex flex-col space-y-1">
          <button 
            onclick="richChat.addReaction('👍', this)"
            class="p-1 bg-gray-600 hover:bg-gray-500 rounded text-xs"
            title="Réagir"
          >
            😊
          </button>
          <button 
            onclick="richChat.copyMessage(this)"
            class="p-1 bg-gray-600 hover:bg-gray-500 rounded text-xs"
            title="Copier"
          >
            📋
          </button>
        </div>
      </div>
    `;

    // Retirer le placeholder si présent
    const placeholder = this.messagesContainer.querySelector('.text-center');
    if (placeholder) {
      placeholder.remove();
    }

    this.messagesContainer.appendChild(messageDiv);
    this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight;
  }

  renderAvatar(name) {
    const initial = name.charAt(0).toUpperCase();
    const colors = ['bg-red-500', 'bg-blue-500', 'bg-green-500', 'bg-yellow-500', 'bg-purple-500', 'bg-pink-500'];
    const color = colors[name.charCodeAt(0) % colors.length];
    
    return `
      <div class="w-8 h-8 ${color} rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
        ${initial}
      </div>
    `;
  }

  parseMarkdown(text) {
    if (!text) return '';

    // Parser simple markdown
    return text
      // Gras : **texte** ou __texte__
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/__(.+?)__/g, '<strong>$1</strong>')
      // Italique : *texte* ou _texte_
      .replace(/\*(.+?)\*/g, '<em>$1</em>')
      .replace(/_(.+?)_/g, '<em>$1</em>')
      // Code inline : `code`
      .replace(/`(.+?)`/g, '<code class="bg-gray-800 px-1 py-0.5 rounded text-xs">$1</code>')
      // Liens : [texte](url)
      .replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2" class="text-blue-300 hover:underline" target="_blank">$1</a>')
      // Nouvelles lignes
      .replace(/\n/g, '<br>');
  }

  addReaction(emoji, buttonElement) {
    const messageDiv = buttonElement.closest('.group');
    const reactionsContainer = messageDiv.querySelector('.reactions');
    
    // Vérifier si la réaction existe déjà
    let reactionSpan = Array.from(reactionsContainer.children).find(
      span => span.textContent.includes(emoji)
    );

    if (reactionSpan) {
      // Incrémenter le compteur
      const count = parseInt(reactionSpan.dataset.count || 1) + 1;
      reactionSpan.dataset.count = count;
      reactionSpan.innerHTML = `${emoji} ${count}`;
    } else {
      // Créer nouvelle réaction
      reactionSpan = document.createElement('span');
      reactionSpan.className = 'inline-flex items-center px-2 py-1 bg-gray-600 hover:bg-gray-500 rounded-full text-xs cursor-pointer transition-colors';
      reactionSpan.dataset.count = 1;
      reactionSpan.innerHTML = emoji;
      reactionsContainer.appendChild(reactionSpan);
    }
  }

  copyMessage(buttonElement) {
    const messageDiv = buttonElement.closest('.group');
    const messageContent = messageDiv.querySelector('.message-content');
    const text = messageContent.textContent;
    
    navigator.clipboard.writeText(text).then(() => {
      buttonElement.textContent = '✓';
      setTimeout(() => {
        buttonElement.textContent = '📋';
      }, 1000);
    });
  }

  setupDragAndDrop() {
    const dropZone = this.messagesContainer;

    dropZone.addEventListener('dragover', (e) => {
      e.preventDefault();
      e.stopPropagation();
      dropZone.classList.add('border-2', 'border-blue-500', 'border-dashed');
    });

    dropZone.addEventListener('dragleave', (e) => {
      e.preventDefault();
      e.stopPropagation();
      dropZone.classList.remove('border-2', 'border-blue-500', 'border-dashed');
    });

    dropZone.addEventListener('drop', (e) => {
      e.preventDefault();
      e.stopPropagation();
      dropZone.classList.remove('border-2', 'border-blue-500', 'border-dashed');

      const files = Array.from(e.dataTransfer.files);
      
      files.forEach(file => {
        this.uploadFile(file);
      });
    });
  }

  uploadFile(file) {
    // Vérifier la taille (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      this.showNotification('❌ Fichier trop volumineux (max 10MB)');
      return;
    }

    // Créer un message temporaire
    const tempMessage = {
      from_name: 'Vous',
      message: `📎 Envoi de ${file.name} (${(file.size / 1024).toFixed(2)} KB)...`,
      formatted: `📎 Envoi de <strong>${file.name}</strong> (${(file.size / 1024).toFixed(2)} KB)...`,
      timestamp: new Date().toISOString(),
      is_own: true
    };

    this.addMessage(tempMessage);

    // TODO: Implémenter upload réel via Phoenix
    console.log('Upload fichier:', file.name);
  }

  showNotification(message) {
    const notification = document.createElement('div');
    notification.className = 'fixed top-20 right-4 bg-gray-800 text-white px-4 py-3 rounded-lg shadow-2xl z-50 animate-slide-in-right';
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
      notification.classList.add('animate-fade-out');
      setTimeout(() => notification.remove(), 300);
    }, 3000);
  }

  formatTime(timestamp) {
    return new Date(timestamp).toLocaleTimeString('fr-FR', {
      hour: '2-digit',
      minute: '2-digit'
    });
  }
}

// Export global pour utilisation dans la page
window.RichChat = RichChat;







