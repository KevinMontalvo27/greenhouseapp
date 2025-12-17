import 'package:flutter/material.dart';
import '../../services/chat_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class GeminiScreen extends StatefulWidget {
  final int chatId;

  const GeminiScreen({super.key, required this.chatId});

  @override
  State<GeminiScreen> createState() => _GeminiScreenState();
}

class _GeminiScreenState extends State<GeminiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  // Estados
  bool _isLoadingMessages = true;
  bool _isSendingMessage = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// PASO 2: Cargar mensajes del chat desde el backend
  Future<void> _loadChatMessages() async {
    setState(() {
      _isLoadingMessages = true;
      _errorMessage = null;
    });

    try {
      print('Cargando mensajes del chat ${widget.chatId}...');
      
      final messages = await ChatService.getChatMessages(widget.chatId);
      
      print('${messages.length} mensajes cargados');

      final chatMessages = messages.map((msg) {
        return ChatMessage(
          text: msg['message'] as String,
          isUser: msg['author'] == 'user',
          timestamp: DateTime.parse(msg['sent_at'] as String),
        );
      }).toList();

      setState(() {
        _messages.clear();
        _messages.addAll(chatMessages);
        _isLoadingMessages = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('Error cargando mensajes: $e');
      setState(() {
        _errorMessage = 'Error al cargar mensajes: ${e.toString()}';
        _isLoadingMessages = false;
      });
    }
  }

  /// PASO 3: Enviar mensaje al backend y recibir respuesta de Gemini
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    
    if (message.isEmpty || _isSendingMessage) return;

    // Guardar referencia al mensaje para retry
    final userMessage = message;

    // Limpiar input inmediatamente
    _messageController.clear();

    // Agregar mensaje del usuario a la UI
    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isSendingMessage = true;
    });

    _scrollToBottom();

    try {
      print('Enviando mensaje a Gemini...');

      // Llamar al servicio para enviar mensaje
      final result = await ChatService.sendMessage(
        chatId: widget.chatId,
        message: userMessage,
      );

      if (!mounted) return;

      if (result['success']) {
        final data = result['data'];
        
        print('DEBUG - Estructura de respuesta:');
        print(data.toString());
        
        // Extraer respuesta de Gemini
        // El backend retorna: { "id": X, "author": "gemini", "message": "...", ... }
        String geminiResponse;
        
        if (data['message'] != null) {
          geminiResponse = data['message'] as String;
          print('Mensaje extraído del campo "message"');
        } else if (data['gemini_response'] != null) {
          geminiResponse = data['gemini_response'] as String;
          print('Mensaje extraído del campo "gemini_response"');
        } else if (data['gemini_message'] != null && 
                   data['gemini_message']['message'] != null) {
          geminiResponse = data['gemini_message']['message'] as String;
          print('Mensaje extraído de "gemini_message.message"');
        } else {
          geminiResponse = 'Respuesta recibida (sin contenido)';
          print('Estructura no reconocida');
        }

        print('Respuesta de Gemini recibida');
        print('Preview: ${geminiResponse.length > 50 ? geminiResponse.substring(0, 50) : geminiResponse}...');

        // Agregar respuesta de Gemini a la UI
        setState(() {
          _messages.add(
            ChatMessage(
              text: geminiResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isSendingMessage = false;
        });

        _scrollToBottom();
      } else {
        // Error al enviar
        print('Error: ${result['message']}');
        
        if (mounted) {
          setState(() {
            _isSendingMessage = false;
          });

          _showErrorSnackBar(
            result['message'] ?? 'Error al enviar mensaje',
            userMessage,
          );
        }
      }
    } catch (e) {
      print('Excepción al enviar: $e');
      
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });

        _showErrorSnackBar(
          'Error de conexión: ${e.toString()}',
          userMessage,
        );
      }
    }
  }

  /// PASO 5: Mostrar error con opción de reintentar
  void _showErrorSnackBar(String error, String originalMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: () {
            // Restaurar mensaje en el input
            _messageController.text = originalMessage;
          },
        ),
      ),
    );
  }

  /// Scroll automático al final
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients && mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.grey.shade50],
            stops: const [0.0, 0.25],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildMessageArea(),
                ),
              ),
              
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/gemini.png',
              width: 28,
              height: 28,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Asistente Gemini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _isSendingMessage ? 'Escribiendo...' : 'Siempre disponible',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageArea() {
    // Estado de loading inicial
    if (_isLoadingMessages) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando conversación...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Estado de error al cargar
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar mensajes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadChatMessages,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Estado vacío
    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'No hay mensajes',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Lista de mensajes + indicador de escritura
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isSendingMessage ? 1 : 0),
      itemBuilder: (context, index) {
        // PASO 4: Mostrar indicador "escribiendo..." al final
        if (index == _messages.length && _isSendingMessage) {
          return _buildTypingIndicator();
        }

        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  /// PASO 4: Indicador de "Gemini está escribiendo..."
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset('assets/gemini.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Gemini está escribiendo',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !_isSendingMessage,
                decoration: InputDecoration(
                  hintText: _isSendingMessage 
                      ? 'Esperando respuesta...' 
                      : 'Escribe tu mensaje...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade700],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: _isSendingMessage
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              color: Colors.white,
              onPressed: _isSendingMessage ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/gemini.png', width: 24, height: 24),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue.shade600 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ],
        ],
      ),
    );
  }
}