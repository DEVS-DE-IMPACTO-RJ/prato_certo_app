import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prato_certo/features/collaborator/presentation/controllers/inventory_controller.dart';

class InventoryFormView extends GetView<InventoryController> {
  const InventoryFormView({super.key});

  @override
  Widget build(BuildContext context) {
    // Injeção Preguiçosa
    Get.lazyPut(() => InventoryController());

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
              const SizedBox(height: 24),

              // --- 1. Nome do Item ---
              TextFormField(
                controller: controller.nameController,
                decoration: _inputDecoration("Nome do Alimento", Icons.restaurant),
                style: const TextStyle(fontSize: 18),
                validator: (value) => value!.isEmpty ? "Digite o nome do alimento" : null,
              ),
              const SizedBox(height: 16),

              // --- 2. Categoria ---
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedCategory.value,
                decoration: _inputDecoration("Categoria", Icons.category),
                items: controller.categories.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat, style: const TextStyle(fontSize: 16))
                )).toList(),
                onChanged: controller.setCategory,
              )),
              const SizedBox(height: 16),

              // --- 3. Quantidade e Unidade ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildCounterButton(
                              icon: Icons.remove,
                              onTap: controller.decrementQuantity,
                              color: Colors.grey.shade700
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: controller.qtdController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                hintText: "0",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                                isDense: true,
                              ),
                              validator: (value) => value!.isEmpty ? "Qtd?" : null,
                            ),
                          ),
                          _buildCounterButton(
                              icon: Icons.add,
                              onTap: controller.incrementQuantity,
                              color: const Color(0xFFF97316)
                          ),
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
                      items: controller.units.map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u)
                      )).toList(),
                      onChanged: controller.setUnit,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- 4. Seção de Validade (NOVO) ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    // O Switch
                    Obx(() => SwitchListTile(
                      title: const Text("Possui data de validade?", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Desmarque para frutas/legumes a granel", style: TextStyle(fontSize: 12)),
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFFF97316),
                      value: controller.hasExpirationDate.value,
                      onChanged: controller.setHasExpirationDate,
                    )),

                    const Divider(),
                    const SizedBox(height: 8),

                    // O Campo de Data (Controlado pelo Switch)
                    Obx(() {
                      final isEnabled = controller.hasExpirationDate.value;
                      return TextFormField(
                        controller: controller.dateDisplayController,
                        readOnly: true,
                        enabled: isEnabled, // Desabilita visualmente
                        onTap: () => controller.pickDate(context),
                        decoration: _inputDecoration("Validade", Icons.calendar_today).copyWith(
                          filled: true,
                          // Cor cinza se desabilitado, branco se habilitado
                          fillColor: isEnabled ? Colors.white : Colors.grey.shade200,
                          suffixIcon: isEnabled ? const Icon(Icons.arrow_drop_down) : null,
                        ),
                        validator: (value) {
                          // Só valida se o campo estiver habilitado
                          if (isEnabled && (value == null || value.isEmpty)) {
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

              // --- Botão Salvar ---
              SizedBox(
                height: 56,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                      height: 24, width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                      : const Text("SALVAR NO ESTOQUE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers de UI ---
  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFF97316)) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      disabledBorder: OutlineInputBorder( // Estilo quando desabilitado
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildCounterButton({required IconData icon, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 54,
        width: 48,
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}