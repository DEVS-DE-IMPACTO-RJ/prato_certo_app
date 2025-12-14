import 'package:get/get.dart';
import 'package:prato_certo/features/beneficiary/data/models/basket_model.dart';
import 'package:prato_certo/features/beneficiary/data/repositories/beneficiary_repository.dart';

class BeneficiaryController extends GetxController {
  final BeneficiaryRepository repository;
  BeneficiaryController(this.repository);

  final isLoading = true.obs;
  final availableBaskets = <BasketModel>[].obs;
  final myBaskets = <BasketModel>[].obs;

  // Hardcoded UserID para o Hackathon
  final int userId = 1;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      // Busca paralela para ganhar tempo
      final results = await Future.wait([
        repository.getAvailableBaskets(),
        repository.getMyInterests(userId)
      ]);

      availableBaskets.assignAll(results[0]);
      myBaskets.assignAll(results[1]);
    } catch (e) {
      print(e);
      Get.snackbar("Erro", "Falha ao carregar cestas: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerInterest(BasketModel basket) async {
    try {
      print(basket);

      await repository.showInterest(basket.id, userId);
      Get.snackbar("Sucesso", "Interesse registrado! Seu Zé foi avisado.");

      // Atualiza as listas localmente para UX imediata
      availableBaskets.remove(basket);
      myBaskets.add(basket);
    } catch (e) {
      print(e);
      Get.snackbar("Erro", "Não foi possível registrar interesse.");
    }
  }
}