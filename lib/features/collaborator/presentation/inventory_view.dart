import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'controllers/inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque do José'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchInventory,
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
                Text(controller.errorMessage.value),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: controller.fetchInventory,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (controller.inventoryList.isEmpty) {
          return const Center(child: Text('Nenhum item encontrado.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.inventoryList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = controller.inventoryList[index];
            final isPerishable = controller.isPerishable(item.category);

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: isPerishable
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.blueGrey.withOpacity(0.1),
                  child: Icon(
                    Icons.inventory_2,
                    color: isPerishable ? Colors.deepOrange : Colors.blueGrey,
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name ?? 'Sem nome',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
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
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Categoria: ${item.category ?? '-'}"),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isPerishable ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Vence: ${controller.formatDate(item.expiresAt)}",
                            style: TextStyle(
                              color: isPerishable
                                  ? Colors.red
                                  : Colors.grey[700],
                              fontWeight: isPerishable
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      // Botão para adicionar (mantendo o gancho para sua feature anterior)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/area-add-estoque');
          // controller.openAddModal(); // Sua lógica de abrir modal
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
