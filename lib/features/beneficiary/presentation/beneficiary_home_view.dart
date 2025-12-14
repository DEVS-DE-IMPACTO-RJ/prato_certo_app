import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Adicione para formatar datas se precisar
import 'package:prato_certo/features/beneficiary/presentation/controllers/beneficiary_controller.dart';
import '../data/repositories/beneficiary_repository.dart';

class BeneficiaryHomeView extends GetView<BeneficiaryController> {
  const BeneficiaryHomeView({Key? key}) : super(key: key);

  // Cores do Tema (Ajuste conforme seu branding)
  final Color primaryColor = const Color(0xFFF97316); // Laranja
  final Color greenColor = const Color(0xFF16A34A);   // Verde
  final Color cardBgColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF3F4F6);      // Cinza claro pro fundo

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => BeneficiaryController(Get.find<BeneficiaryRepository>()));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Olá, Maria 👋",
                style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              Text(
                "Encontre alimentos perto de você",
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
          bottom: TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Disponíveis"),
              Tab(text: "Minhas Cestas"),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          return TabBarView(children: [
            _buildAvailableList(context),
            _buildMyList(context)
          ]);
        }),
      ),
    );
  }

  // --- ABA 1: DISPONÍVEIS ---
  Widget _buildAvailableList(BuildContext context) {
    if (controller.availableBaskets.isEmpty) {
      return _buildEmptyState(
          "Nenhuma cesta disponível", "Fique de olho, avisaremos quando chegar!", Icons.storefront_outlined);
    }
    return ListView.separated(
      itemCount: controller.availableBaskets.length,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final basket = controller.availableBaskets[index];
        return Container(
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do Card com Faixa Colorida
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.shopping_basket_outlined, color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            basket.titulo,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  basket.estabelecimento ?? "Local não informado",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        basket.peso ?? "N/A",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),

              // Resumo dos Itens
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("O que vem na cesta?",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text(
                        basket.alimentos.take(5).join(', ') + (basket.alimentos.length > 5 ? '...' : ''),
                        style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // Ações
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pushNamed('receitas-detalhes', extra: basket),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Ver Detalhes"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.registerInterest(basket),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("QUERO BUSCAR", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- ABA 2: MINHAS CESTAS ---
  Widget _buildMyList(BuildContext context) {
    if (controller.myBaskets.isEmpty) {
      return _buildEmptyState(
          "Você ainda não agendou nada", "Vá na aba 'Disponíveis' e garanta sua cesta!", Icons.shopping_bag_outlined);
    }
    return ListView.separated(
      itemCount: controller.myBaskets.length,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final basket = controller.myBaskets[index];
        return InkWell(
          onTap: () => context.pushNamed('receitas-detalhes', extra: basket),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: greenColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(color: greenColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: greenColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.check_circle_outline, color: greenColor, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: greenColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text("AGENDADO",
                              style: TextStyle(
                                  color: greenColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          basket.titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Retirar em: ${basket.endereco ?? 'Local a definir'}",
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Widget Auxiliar para Tela Vazia ---
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}