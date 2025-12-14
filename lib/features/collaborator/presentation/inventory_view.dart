import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Mantemos apenas para o State Management (Obx, GetView)
import 'package:go_router/go_router.dart';

import 'controllers/inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controller para o campo de texto
    final TextEditingController urlInputController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque do José'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchInventory,
            tooltip: 'Atualizar Lista',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.fetchInventory,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (controller.inventoryList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Nenhum item no estoque.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: controller.inventoryList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = controller.inventoryList[index];
            final isPerishable = controller.isPerishable(item.category);

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: isPerishable
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.blueGrey.withOpacity(0.1),
                  child: Icon(
                    Icons.inventory_2,
                    color: isPerishable ? Colors.deepOrange : Colors.blueGrey,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name ?? 'Sem nome',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        "${item.quantity?.toStringAsFixed(0) ?? 0} ${item.unit ?? ''}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text("Categoria: ${item.category ?? '-'}"),
              ),
            );
          },
        );
      }),

      // --- CORREÇÃO AQUI: Usando showDialog nativo ---
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'btnAI',
            backgroundColor: Colors.deepPurple,
            icon: const Icon(Icons.link, color: Colors.white),
            label: const Text(
              "Colar URL (IA)",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              urlInputController.clear();

              // 1. Usamos showDialog em vez de Get.defaultDialog
              showDialog(
                context: context, // O context agora existe e é válido
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Adicionar via IA", style: TextStyle(color: Colors.deepPurple)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min, // Importante para não quebrar layout
                      children: [
                        const Text(
                          "Cole o link de uma imagem para a IA identificar.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: urlInputController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'URL da Imagem',
                            hintText: 'https://...',
                            prefixIcon: Icon(Icons.link),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
                        onPressed: () => Navigator.of(context).pop(), // Fecha nativamente
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                        child: const Text("PROCESSAR", style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          final url = urlInputController.text;
                          if (url.isNotEmpty) {
                            Navigator.of(context).pop(); // Fecha o dialog
                            controller.uploadImageUrl(url); // Chama o controller
                          } else {
                            // SnackBar nativo (já que Get.snackbar pode falhar também)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cole uma URL válida.')),
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),

          FloatingActionButton(
            heroTag: 'btnAdd',
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              context.go('/area-add-estoque');
            },
            tooltip: 'Adicionar Manualmente',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}