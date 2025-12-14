import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prato_certo/features/beneficiary/presentation/controllers/smart_recipe_controller.dart';
import '../data/models/basket_model.dart';
import '../data/repositories/beneficiary_repository.dart';

class RecipeHubView extends GetView<SmartRecipeController> {
  final BasketModel basket;

  const RecipeHubView({Key? key, required this.basket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Injeta o controller passando a cesta atual
    Get.put(SmartRecipeController(Get.find<BeneficiaryRepository>(), basket));

    return Scaffold(
      appBar: AppBar(title: Text(basket.titulo)),
      body: Column(
        children: [
          // 1. Resumo dos Itens (Colapsável ou fixo pequeno)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Itens desta cesta:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: basket.alimentos.map((e) => Chip(
                    label: Text(e, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.white,
                  )).toList(),
                ),
              ],
            ),
          ),

          // 2. Filtros de Restrição (Sempre visível para fácil acesso)
          ExpansionTile(
            title: const Text("Tenho restrições alimentares", style: TextStyle(color: Colors.blue)),
            children: [
              Obx(() => Wrap(
                spacing: 8,
                children: controller.availableRestrictions.map((restriction) {
                  final isSelected = controller.selectedRestrictions.contains(restriction);
                  return FilterChip(
                    label: Text(restriction),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleRestriction(restriction),
                    selectedColor: Colors.blue.shade100,
                  );
                }).toList(),
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Atualizar Receitas com minhas restrições"),
                  onPressed: controller.loadSpecialRecipes,
                ),
              )
            ],
          ),

          const Divider(),

          // 3. Botões de Ação (Abas Lógicas)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton("Dicas Básicas", 0),
                _buildTabButton("Personalizado", 1),
                _buildTabButton("Zero Desperdício", 2, icon: Icons.eco),
              ],
            ),
          ),

          const Divider(),

          // 4. Conteúdo Dinâmico (Receitas e Dicas)
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

              final data = controller.currentRecipeData.value;
              if (data == null) return const Center(child: Text("Selecione uma opção acima"));

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Alerta de Substituições (Se houver)
                  if (data.alimentosRemovidos != null && data.alimentosRemovidos!.isNotEmpty)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("⚠️ Atenção às substituições:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            ...data.alimentosRemovidos!.map((e) => Text("• ${e.alimento}: ${e.motivo}. Tente usar: ${e.substituto}")),
                          ],
                        ),
                      ),
                    ),

                  // Dicas Nutricionais
                  if (data.dicasNutricionais.isNotEmpty) ...[
                    const Text("💡 Dicas do Nutricionista", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...data.dicasNutricionais.map((d) => Card(
                      child: ListTile(leading: const Icon(Icons.lightbulb_outline, color: Colors.amber), title: Text(d)),
                    )),
                    const SizedBox(height: 20),
                  ],

                  // Receitas
                  const Text("🍳 Receitas Sugeridas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...data.receitas.map((recipe) => _buildRecipeCard(recipe)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index, {IconData? icon}) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return InkWell(
        onTap: () {
          if (index == 0) controller.loadStandardTips();
          if (index == 1) controller.loadSpecialRecipes();
          if (index == 2) controller.loadSaveFoodRecipes();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              if (icon != null) Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black),
              if (icon != null) const SizedBox(width: 4),
              Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(recipe.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Tempo: ${recipe.tempoPreparo} • ${recipe.porcoes}"),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ingredientes:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(recipe.ingredientes.join(", ")),
                const SizedBox(height: 10),
                const Text("Modo de Preparo:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(recipe.modoPreparo),
              ],
            ),
          )
        ],
      ),
    );
  }
}