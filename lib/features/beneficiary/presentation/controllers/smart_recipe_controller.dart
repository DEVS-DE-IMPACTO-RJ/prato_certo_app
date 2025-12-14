import 'package:get/get.dart';
import 'package:prato_certo/features/beneficiary/data/models/basket_model.dart';
import 'package:prato_certo/features/beneficiary/data/repositories/beneficiary_repository.dart';

class SmartRecipeController extends GetxController {
  final BeneficiaryRepository repository;
  final BasketModel basket; // Recebe a cesta via argumento ou construtor

  SmartRecipeController(this.repository, this.basket);

  final isLoading = false.obs;
  final currentRecipeData = Rxn<RecipeResponse>();

  // Estado das Restrições
  final availableRestrictions = ["sem lactose", "sem glúten", "vegetariana", "vegana", "sem açúcar", "hipertensão"];
  final selectedRestrictions = <String>[].obs;

  // Tabs
  final selectedTab = 0.obs; // 0 = Dicas, 1 = Personalizado, 2 = Salvar Alimentos

  @override
  void onInit() {
    super.onInit();
    loadStandardTips();
  }

  void toggleRestriction(String restriction) {
    if (selectedRestrictions.contains(restriction)) {
      selectedRestrictions.remove(restriction);
    } else {
      selectedRestrictions.add(restriction);
    }
    // Recarrega automaticamente se estiver na aba de personalizado
    if (selectedTab.value == 1) loadSpecialRecipes();
  }

  Future<void> loadStandardTips() async {
    isLoading.value = true;
    try {
      final result = await repository.getStandardTips(basket.id);
      currentRecipeData.value = result;
      selectedTab.value = 0;
    } catch (e) {
      Get.snackbar("Erro", "Falha ao carregar dicas");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSpecialRecipes() async {
    isLoading.value = true;
    try {
      final result = await repository.getSpecialRecipes(basket.id, selectedRestrictions.toList());
      currentRecipeData.value = result;
      selectedTab.value = 1;
    } catch (e) {
      Get.snackbar("Erro", "Falha ao personalizar receitas");
    } finally {
      isLoading.value = false;
    }
  }

  // Modo "O que tem na geladeira" + Cesta
  Future<void> loadSaveFoodRecipes() async {
    isLoading.value = true;
    try {
      // Usa os alimentos da cesta atual + lógica extra se necessário
      final result = await repository.getSaveFoodRecipes(basket.alimentos, selectedRestrictions.toList());
      currentRecipeData.value = result;
      selectedTab.value = 2;
    } catch (e) {
      Get.snackbar("Erro", "Falha ao gerar receitas econômicas");
    } finally {
      isLoading.value = false;
    }
  }
}