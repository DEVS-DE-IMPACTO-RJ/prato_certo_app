import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart' as dio_pkg;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart' as dio_client;
import 'package:intl/intl.dart';
import 'package:prato_certo/core/network/agent_api_service.dart';
import 'package:prato_certo/features/collaborator/data/models/inventory_item.dart';

class InventoryController extends GetxController {
  // --- DEPENDÊNCIAS ---
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // --- CONTROLLERS DE TEXTO (Formulário Principal) ---
  late TextEditingController nameController;
  late TextEditingController qtdController;
  late TextEditingController dateDisplayController;

  // --- CONTROLLERS DE TEXTO (Tela de IA) ---
  late TextEditingController aiNameResultController;

  // --- ESTADOS (LISTAGEM) ---
  final inventoryList = <InventoryItem>[].obs;
  final isLoadingList = true.obs;
  final errorMessage = ''.obs;

  // --- ESTADOS (FORMULÁRIO & IA) ---
  final isLoading = false.obs;
  final isAnalyzingImage = false.obs;

  final Rx<XFile?> selectedImage = Rx<XFile?>(null);

  // Resultado temporário da IA
  final aiResultName = ''.obs;
  final aiResultCategory = ''.obs;

  // --- CAMPOS DO FORMULÁRIO ---
  final RxString selectedCategory = 'Não perecivel'.obs;
  final RxString selectedUnit = 'kg'.obs;
  final RxBool hasExpirationDate = true.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  final List<String> categories = ['Não perecivel', 'Perecivel', 'Hortifruti', 'Limpeza'];
  final List<String> units = ['kg', 'un', 'L', 'g', 'cx'];

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    qtdController = TextEditingController();
    dateDisplayController = TextEditingController();
    aiNameResultController = TextEditingController();

    // Carrega a lista ao iniciar
    fetchInventory();
  }

  @override
  void onClose() {
    nameController.dispose();
    qtdController.dispose();
    dateDisplayController.dispose();
    aiNameResultController.dispose();
    super.onClose();
  }

  // ===========================================================================
  // 1. LÓGICA DE LISTAGEM
  // ===========================================================================
  Future<void> fetchInventory() async {
    try {
      isLoadingList.value = true;
      errorMessage.value = '';
      final result = await _apiService.getInventoryItems();
      inventoryList.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Erro ao buscar: $e';
    } finally {
      isLoadingList.value = false;
    }
  }

  // ===========================================================================
  // 2. LÓGICA DE IMAGEM E I.A.
  // ===========================================================================

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1024,
          maxHeight: 1024
      );

      if (picked != null) {
        selectedImage.value = picked;
        // Limpa resultados anteriores
        aiResultName.value = '';
        aiNameResultController.clear();

        await _uploadAndAnalyzeImage(picked);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível selecionar a imagem');
    }
  }

  Future<void> _uploadAndAnalyzeImage(XFile file) async {
    try {
      isAnalyzingImage.value = true;

      // 1. Upload Firebase
      String fileName = 'inventory_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('ai_uploads').child(fileName);

      UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        uploadTask = ref.putFile(File(file.path));
      }

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Url Firebase: $downloadUrl");

      // 2. Analisar na API
      await _sendUrlToAiApi(downloadUrl);

    } catch (e) {
      print(e);
      Get.snackbar('Erro', 'Falha no processamento: $e');
    } finally {
      isAnalyzingImage.value = false;
    }
  }

  Future<void> _sendUrlToAiApi(String imageUrl) async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=ku8NfFhNbKINqkudZdPmTYTf1QJDzOC2aFS7d0EAf5w8bOySnY2seTixQsNOb4xc'
    };
    var data = { "imageUrl": imageUrl };
    var dio = dio_client.Dio();

    try {
      var url = kIsWeb
          ? 'https://collaborator.pratocerto.xpertapps.tech/collaborators/ai/photos'
          : 'https://collaborator.pratocerto.xpertapps.tech/collaborators/ai/photos';

      var response = await dio.post(
        url,
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map) {
          if (responseData['name'] != null) {
            aiResultName.value = responseData['name'].toString();
            aiNameResultController.text = responseData['name'].toString();
          }
          if (responseData['category'] != null && categories.contains(responseData['category'])) {
            aiResultCategory.value = responseData['category'].toString();
          }
        }
      } else {
        Get.snackbar('Atenção', 'A IA não identificou o produto com clareza.');
      }
    } catch (e) {
      print('Erro API IA: $e');
      Get.snackbar('Erro', 'Falha na comunicação com a IA.');
    }
  }

  void confirmAiData() {
    if (aiNameResultController.text.isNotEmpty) {
      nameController.text = aiNameResultController.text;
    }
    if (aiResultCategory.value.isNotEmpty && categories.contains(aiResultCategory.value)) {
      selectedCategory.value = aiResultCategory.value;
    }
    Get.back();
  }

  // ===========================================================================
  // 3. SALVAR NO ESTOQUE
  // ===========================================================================

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    if (hasExpirationDate.value && selectedDate.value == null) {
      Get.snackbar('Erro', "Selecione a validade");
      return;
    }

    isLoading.value = true;
    try {
      // Tratamento de campos se tiver imagem (ignora validação estrita)
      String finalName = nameController.text.trim();
      if (finalName.isEmpty) {
        finalName = "Item da Foto (Processando...)";
      }

      double finalQtd = 0.0;
      if (qtdController.text.isNotEmpty) {
        finalQtd = double.parse(qtdController.text.replaceAll(',', '.'));
      } else {
        finalQtd = 1.0;
      }

      await _apiService.addInventoryItem(
        name: finalName,
        category: selectedCategory.value,
        quantity: finalQtd,
        unit: selectedUnit.value,
        expiresAt: hasExpirationDate.value ? selectedDate.value : null,
      );

      _clearForm();
      await fetchInventory();
      Get.back();
      Get.snackbar('Sucesso', 'Item salvo!');

    } catch (e) {
      Get.snackbar('Erro', 'Falha ao salvar: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    nameController.clear();
    qtdController.clear();
    dateDisplayController.clear();
    aiNameResultController.clear();
    selectedDate.value = null;
    selectedImage.value = null;
    hasExpirationDate.value = true;
    selectedCategory.value = 'Não perecivel';
    aiResultCategory.value = '';
    aiResultName.value = '';
  }

  // ===========================================================================
  // 4. HELPERS DE UI (Data e Perecível)
  // ===========================================================================

  void setHasExpirationDate(bool value) {
    hasExpirationDate.value = value;
    if (!value) {
      selectedDate.value = null;
      dateDisplayController.clear();
    }
  }
  void setCategory(String? value) { if (value != null) selectedCategory.value = value; }
  void setUnit(String? value) { if (value != null) selectedUnit.value = value; }

  Future<void> pickDate(BuildContext context) async {
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
    double current = double.tryParse(qtdController.text.replaceAll(',', '.')) ?? 0.0;
    current++;
    qtdController.text = current % 1 == 0 ? current.toInt().toString() : current.toString().replaceAll('.', ',');
  }
  void decrementQuantity() {
    double current = double.tryParse(qtdController.text.replaceAll(',', '.')) ?? 0.0;
    if (current > 0) current--;
    qtdController.text = current % 1 == 0 ? current.toInt().toString() : current.toString().replaceAll('.', ',');
  }

  // --- AQUI ESTÃO OS MÉTODOS QUE FALTAVAM ---

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }
// No seu InventoryController
// ... outros imports



// ... class InventoryController ...

  Future<void> uploadImageUrl(String urlImage) async {
    if (urlImage.trim().isEmpty) {
      Get.snackbar('Atenção', 'A URL não pode estar vazia');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print("Enviando URL: $urlImage");

      // --- Configuração da Requisição ---
      var headers = {
        'Content-Type': 'application/json',
        // Cookie fixo conforme solicitado
        'Cookie': 'csrftoken=ku8NfFhNbKINqkudZdPmTYTf1QJDzOC2aFS7d0EAf5w8bOySnY2seTixQsNOb4xc'
      };

      var data = json.encode({
        "imageUrl": urlImage.trim()
      });

      var dio = dio_client.Dio();

      // Timeout de segurança
      dio.options.sendTimeout = const Duration(seconds: 30);

      var response = await dio.post(
        'https://collaborator.pratocerto.xpertapps.tech/collaborators/ai/photos',
        options: dio_client.Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Resposta da IA: ${json.encode(response.data)}");

        Get.snackbar(
          'Sucesso!',
          'Imagem processada pela IA.',
          backgroundColor: Get.theme.primaryColorLight,
          duration: const Duration(seconds: 4),
        );

        // Atualiza a lista para mostrar o novo item
        fetchInventory();
      } else {
        print('Erro Status: ${response.statusCode}');
        errorMessage.value = 'Erro API: ${response.statusCode}';
        Get.snackbar('Erro', 'O servidor rejeitou a URL.');
      }

    } catch (e) {
      print('Erro ao enviar URL: $e');
      errorMessage.value = 'Erro de conexão.';
      Get.snackbar('Erro', 'Falha ao conectar com a IA.');

      if (e is dio_client.DioException) {
        print("Detalhe do erro: ${e.response?.data}");
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool isPerishable(String? category) {
    if (category == null) return false;
    final normalized = category.toLowerCase();
    // Adicione aqui as categorias que você considera perecíveis
    return normalized.contains('perecivel') ||
        normalized.contains('hortifruti') ||
        normalized.contains('laticinio') ||
        normalized.contains('carne');
  }
}