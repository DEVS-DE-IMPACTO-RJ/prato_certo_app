import 'package:flutter/material.dart';
import 'package:prato_certo/core/router/app_router.dart'; // Importa a chave daqui

class FeedbackDialogs {

  static void showSuccess({required String message, required VoidCallback onPressed}) {
    // Pega o contexto global
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FeedbackBaseDialog(
        icon: Icons.check_circle,
        color: Colors.green,
        title: "Sucesso!",
        message: message,
        buttonText: "CONTINUAR",
        onPressed: onPressed, // Quem chamar decide o que fazer
      ),
    );
  }

  static void showError({required String message}) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (_) => _FeedbackBaseDialog(
        icon: Icons.error,
        color: Colors.red,
        title: "Algo deu errado",
        message: message,
        buttonText: "TENTAR NOVAMENTE",
        onPressed: () => Navigator.of(context).pop(), // Fecha sozinho
      ),
    );
  }
}

// --- WIDGET VISUAL (Mantive igual, só copiei pra ficar completo) ---
class _FeedbackBaseDialog extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const _FeedbackBaseDialog({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}