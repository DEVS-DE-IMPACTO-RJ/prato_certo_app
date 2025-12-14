import 'dart:io';
import 'package:flutter/foundation.dart'; // <--- IMPORTANTE
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prato_certo/features/collaborator/presentation/controllers/inventory_controller.dart';

class AiScanView extends GetView<InventoryController> {
  const AiScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear com IA"),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ÁREA DE IMAGEM / CAMERA
            Obx(() {
              if (controller.isAnalyzingImage.value) {
                return _buildLoadingState();
              }
              if (controller.selectedImage.value != null) {
                return _buildImagePreview();
              }
              return _buildCameraButtons();
            }),

            const SizedBox(height: 32),

            // RESULTADOS DA IA
            Obx(() {
              if (controller.selectedImage.value == null || controller.isAnalyzingImage.value) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("A IA identificou:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  TextField(
                    controller: controller.aiNameResultController,
                    decoration: const InputDecoration(
                      labelText: "Nome Identificado",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.auto_awesome, color: Colors.orange),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (controller.aiResultCategory.value.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.category, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(child: Text("Categoria sugerida: ${controller.aiResultCategory.value}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: controller.confirmAiData,
                      icon: const Icon(Icons.check),
                      label: const Text("USAR ESTES DADOS"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                      onPressed: () {
                        controller.selectedImage.value = null;
                      },
                      child: const Text("Tentar outra foto")
                  )
                ],
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButtons() {
    return Column(
      children: [
        const Icon(Icons.center_focus_weak, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          "Tire uma foto do produto ou da nota fiscal",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _BigButton(
                icon: Icons.camera_alt,
                label: "CÂMERA",
                onTap: () => controller.pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _BigButton(
                icon: Icons.photo_library,
                label: "GALERIA",
                onTap: () => controller.pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFF97316)),
          SizedBox(height: 16),
          Text("Enviando para IA...", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF97316))),
          SizedBox(height: 8),
          Text("Isso pode levar alguns segundos", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    // AQUI TAMBÉM PRECISA DO KISWEB
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: kIsWeb
          ? Image.network(
        controller.selectedImage.value!.path,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
      )
          : Image.file(
        File(controller.selectedImage.value!.path),
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BigButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF97316)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFFF97316)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF97316))),
          ],
        ),
      ),
    );
  }
}