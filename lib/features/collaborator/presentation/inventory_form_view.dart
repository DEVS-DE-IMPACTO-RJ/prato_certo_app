import 'dart:io';
import 'package:flutter/foundation.dart'; // <--- OBRIGATÓRIO PARA kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:prato_certo/features/collaborator/presentation/controllers/inventory_controller.dart';
import 'ai_scan_view.dart';

class InventoryFormView extends GetView<InventoryController> {
  const InventoryFormView({super.key});

  @override
  Widget build(BuildContext context) {
    // Garante que o controller existe
    if (!Get.isRegistered<InventoryController>()) {
      Get.lazyPut(() => InventoryController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar ao Estoque"),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "O que chegou hoje?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 16),

              // --- BOTÃO DE IMAGEM / PREVIEW ---
/*
              Obx(() {
                // Se já tem imagem selecionada, mostra miniatura
                if (controller.selectedImage.value != null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF97316)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          // CORREÇÃO DO ERRO DE TELA VERMELHA NO WEB:
                          child: kIsWeb
                              ? Image.network(
                            controller.selectedImage.value!.path,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          )
                              : Image.file(
                            File(controller.selectedImage.value!.path),
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Imagem Anexada", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF97316))),
                              Text("Dados da IA preenchidos", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () =>Get.to(AiScanView()),
                        )
                      ],
                    ),
                  );
                }

                // Se não tem imagem
                return SizedBox(
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => const AiScanView());
                    },
                    icon: const Icon(Icons.camera_enhance),
                    label: const Text("ESCANEAR PRODUTO COM IA"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF97316),
                      side: const BorderSide(color: Color(0xFFF97316)),
                      elevation: 0,
                    ),
                  ),
                );
              }),
*/

              const SizedBox(height: 24),

              // --- CORREÇÃO DO ERRO DO GETX (Improper Use) ---
              Obx(() {
                // TRUQUE: Ler a variável AQUI FORA para o Obx registrar que depende dela.
                // Se ler só dentro do validator, o GetX não vê.
                final hasImage = controller.selectedImage.value != null;

                return TextFormField(
                  controller: controller.nameController,
                  decoration: _inputDecoration("Nome do Alimento", Icons.restaurant),
                  style: const TextStyle(fontSize: 18),
                  validator: (value) {
                    // Se tem imagem, não valida o texto
                    if (hasImage) return null;
                    return value == null || value.isEmpty ? "Digite o nome" : null;
                  },
                );
              }),

              const SizedBox(height: 16),

              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedCategory.value,
                decoration: _inputDecoration("Categoria", Icons.category),
                items: controller.categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: controller.setCategory,
              )),

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          _buildCounterButton(icon: Icons.remove, onTap: controller.decrementQuantity, color: Colors.grey.shade700),
                          Expanded(
                            // MESMA CORREÇÃO DO GETX AQUI
                            child: Obx(() {
                              final hasImage = controller.selectedImage.value != null;

                              return TextFormField(
                                controller: controller.qtdController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(hintText: "0", border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 16), isDense: true),
                                validator: (value) {
                                  if (hasImage) return null;
                                  return value == null || value.isEmpty ? "Qtd?" : null;
                                },
                              );
                            }),
                          ),
                          _buildCounterButton(icon: Icons.add, onTap: controller.incrementQuantity, color: const Color(0xFFF97316)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedUnit.value,
                      decoration: _inputDecoration("Unid.", null),
                      items: controller.units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: controller.setUnit,
                    )),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.grey.shade50),
                child: Column(
                  children: [
                    Obx(() => SwitchListTile(
                      title: const Text("Possui validade?", style: TextStyle(fontWeight: FontWeight.bold)),
                      activeColor: const Color(0xFFF97316),
                      value: controller.hasExpirationDate.value,
                      onChanged: controller.setHasExpirationDate,
                    )),
                    const Divider(),
                    Obx(() {
                      final isEnabled = controller.hasExpirationDate.value;
                      // Aqui também lemos a imagem caso queira remover validação de data
                      final hasImage = controller.selectedImage.value != null;

                      return TextFormField(
                        controller: controller.dateDisplayController,
                        readOnly: true,
                        enabled: isEnabled,
                        onTap: () => controller.pickDate(context),
                        decoration: _inputDecoration("Data de Validade", Icons.calendar_today).copyWith(filled: true, fillColor: isEnabled ? Colors.white : Colors.grey.shade200),
                        validator: (value) {
                          if (isEnabled && (value == null || value.isEmpty)) {
                            // Se preferir que a data seja opcional com imagem, descomente abaixo:
                            // if (hasImage) return null;
                            return "Selecione a data";
                          }
                          return null;
                        },
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: controller.isLoading.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("SALVAR NO ESTOQUE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFF97316)) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF97316), width: 2)),
      filled: true,
      fillColor: Colors.white,
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    );
  }

  Widget _buildCounterButton({required IconData icon, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(height: 54, width: 48, alignment: Alignment.center, child: Icon(icon, color: color, size: 24)),
    );
  }
}