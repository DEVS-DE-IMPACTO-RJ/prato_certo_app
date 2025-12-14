import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prato_certo/core/network/agent_api_service.dart';
import 'package:prato_certo/core/router/app_router.dart';
import 'package:prato_certo/core/ui/feedback_dialogs.dart';
import 'package:prato_certo/features/collaborator/data/models/inventory_item.dart';

class InventoryController extends GetxController {
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController qtdController;
  late TextEditingController dateDisplayController;

  // Estados da Lista
  final isLoading = true.obs;
  final inventoryList = <InventoryItem>[].obs;
  final errorMessage = ''.obs;

  // Estados do Formulário
  final RxString selectedCategory = 'Não perecivel'.obs;
  final RxString selectedUnit = 'kg'.obs;

  // --- NOVA LÓGICA: Controle de Validade ---
  final RxBool hasExpirationDate = true.obs; // Toggle
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  final List<String> categories = ['Não perecivel', 'Perecivel', 'Hortifruti']; // Adicionei Hortifruti como exemplo
  final List<String> units = ['kg', 'un', 'L', 'g', 'cx'];

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    qtdController = TextEditingController();
    dateDisplayController = TextEditingController();
    fetchInventory();
  }

  @override
  void onClose() {
    nameController.dispose();
    qtdController.dispose();
    dateDisplayController.dispose();
    super.onClose();
  }

  Future<void> fetchInventory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _apiService.getInventoryItems();
      inventoryList.assignAll(result);

    } catch (e) {
      errorMessage.value = 'Erro ao buscar estoque: $e';
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Lógica do Toggle de Validade ---
  void setHasExpirationDate(bool value) {
    hasExpirationDate.value = value;
    if (!value) {
      // Se desmarcar, limpa a data visualmente e logicamente
      selectedDate.value = null;
      dateDisplayController.clear();
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Indeterminado'; // ou 'N/A', 'Granel'
    return DateFormat('dd/MM/yyyy').format(date);
  }

  bool isPerishable(String? category) {
    return category?.toLowerCase().contains('perecivel') ?? false;
  }

  void setCategory(String? value) { if (value != null) selectedCategory.value = value; }
  void setUnit(String? value) { if (value != null) selectedUnit.value = value; }

  Future<void> pickDate(BuildContext context) async {
    // Bloqueia se o toggle estiver desligado
    if (!hasExpirationDate.value) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      selectedDate.value = picked;
      dateDisplayController.text = "${picked.day.toString().padLeft(2,'0')}/${picked.month.toString().padLeft(2,'0')}/${picked.year}";
    }
  }

  void incrementQuantity() {
    String text = qtdController.text.replaceAll(',', '.');
    double current = text.isEmpty ? 0.0 : (double.tryParse(text) ?? 0.0);
    current++;
    _updateQtdText(current);
  }

  void decrementQuantity() {
    String text = qtdController.text.replaceAll(',', '.');
    double current = text.isEmpty ? 0.0 : (double.tryParse(text) ?? 0.0);
    if (current > 0) {
      current--;
      if (current < 0) current = 0;
      _updateQtdText(current);
    }
  }

  void _updateQtdText(double val) {
    qtdController.text = val % 1 == 0 ? val.toInt().toString() : val.toString().replaceAll('.', ',');
  }

  Future<void> submitForm() async {
    // 1. Validações básicas dos campos de texto
    if (!formKey.currentState!.validate()) return;

    // 2. Validação Condicional da Data
    // Só reclama da data vazia se o produto TIVER validade
    if (hasExpirationDate.value && selectedDate.value == null) {
      FeedbackDialogs.showError(message: "Por favor, selecione a validade do item.");
      return;
    }

    isLoading.value = true;
    try {
      await _apiService.addInventoryItem(
        name: nameController.text,
        category: selectedCategory.value,
        quantity: double.parse(qtdController.text.replaceAll(',', '.')),
        unit: selectedUnit.value,
        // Envia NULL se o toggle estiver desligado
        expiresAt: hasExpirationDate.value ? selectedDate.value : null,
      );

      // --- SUCESSO ---
      FeedbackDialogs.showSuccess(
          message: "${nameController.text} adicionado com sucesso!",
          onPressed: () {
            Navigator.of(rootNavigatorKey.currentContext!).pop();
            _clearForm();
            fetchInventory(); // Atualiza a lista ao fechar
          }
      );

    } catch (e) {
      FeedbackDialogs.showError(message: "Falha ao conectar com o servidor.");
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    nameController.clear();
    qtdController.clear();
    dateDisplayController.clear();
    selectedDate.value = null;
    hasExpirationDate.value = true; // Reseta o toggle para o padrão
    selectedCategory.value = 'Não perecivel';
    selectedUnit.value = 'kg';
  }
}