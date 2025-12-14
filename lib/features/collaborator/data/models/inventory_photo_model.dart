import 'package:image_picker/image_picker.dart';

// Enum para facilitar a categoria
enum FoodCategory { perishable, nonPerishable }

// Classe auxiliar para guardar a foto e sua categoria antes do upload
class InventoryPhoto {
  final XFile file;
  final FoodCategory category;

  InventoryPhoto({required this.file, required this.category});
}