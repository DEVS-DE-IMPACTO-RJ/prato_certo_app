import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prato_certo/features/collaborator/presentation/inventory_view.dart';
import 'package:prato_certo/features/presentation/home.dart';

import '../../features/collaborator/presentation/inventory_form_view.dart';
// Adicione outros imports de telas aqui se tiver (Login, etc)

// --- 1. A CHAVE MESTRA (IMPORTANTE) ---
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: rootNavigatorKey, // <--- 2. CONECTADA AQUI
  initialLocation: '/',
  debugLogDiagnostics: true,
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text("Página não encontrada (404)")),
  ),
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/area-add-estoque',
      name: 'area-add-estoque',
      builder: (context, state) => const InventoryFormView(),
    ),GoRoute(
      path: '/area-colaborador',
      name: 'area-colaborador',
      builder: (context, state) => const InventoryView(),
    ),
    // Adicione suas outras rotas aqui...
  ],
);