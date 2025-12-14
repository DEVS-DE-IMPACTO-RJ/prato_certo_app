import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prato_certo/features/beneficiary/presentation/recipe_hub_view.dart';
import 'package:prato_certo/features/presentation/home.dart';

import '../../features/beneficiary/presentation/beneficiary_home_view.dart';
import '../../features/collaborator/presentation/ai_scan_view.dart';
import '../../features/collaborator/presentation/inventory_view.dart';
import '../../features/collaborator/presentation/inventory_form_view.dart';

import '../../features/beneficiary/data/models/basket_model.dart';

// --- 1. A CHAVE MESTRA ---
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text("Página não encontrada (404)")),
  ),
  routes: [
    // --- Rota Principal ---
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeView(),
    ),

    // --- Rotas do Colaborador (Seu Zé) ---
    GoRoute(
      path: '/area-add-estoque',
      name: 'area-add-estoque',
      builder: (context, state) => const InventoryFormView(),
    ),
    GoRoute(
      path: '/area-colaborador',
      name: 'area-colaborador',
      builder: (context, state) => const InventoryView(),
    ),

    // --- NOVAS ROTAS: Beneficiário (Dona Maria) ---
    GoRoute(
      path: '/area-beneficiario',
      name: 'area-beneficiario',
      builder: (context, state) => const BeneficiaryHomeView(),
    ),
    GoRoute(
      path: '/ai-scan',
      name: 'ai-scan',
      builder: (context, state) => const AiScanView(),
    ),

    // Rota de Detalhes (Recebe o objeto BasketModel via 'extra')
    GoRoute(
      path: '/receitas-detalhes',
      name: 'receitas-detalhes',
      builder: (context, state) {
        // Recupera o objeto passado na navegação
        final basket = state.extra as BasketModel;
        return RecipeHubView(basket: basket);
      },
    ),
  ],
);