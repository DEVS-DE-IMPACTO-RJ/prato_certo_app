import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/prato_certo_colors.dart'; // Adicione google_fonts: ^6.1.0 se puder, senão use padrão

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // SafeArea garante que não corte em celulares com notch
      body: SafeArea(
        child: Column(
          children: [
            const _NavBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Breakpoint simples: Se maior que 900px é Desktop
                      if (constraints.maxWidth > 900) {
                        return const _DesktopHero();
                      } else {
                        return const _MobileHero();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Componentes Privados para Organização ---

class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder na Nav para esconder botões no mobile se necessário
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo e Nome
          Row(
            children: [
              SvgPicture.asset(
                width: 25,
                height: 25,
                'imgs/logo.svg',
                colorFilter: const ColorFilter.mode(
                  kPrimaryOrange,
                  BlendMode.srcIn,
                ),
                semanticsLabel: 'Red dash paths',
              ),
              const SizedBox(width: 8),
              Text(
                'PratoCerto',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          // Menu Desktop (escondido em telas pequenas)
          if (MediaQuery.of(context).size.width > 800)
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Início",
                    style: TextStyle(color: Color(0xFFF97316)),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Mapa de ONGs",
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Dicas Nutricionais",
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),

          // Botões de Ação (Ajustados para Mobile)
          Row(
            children: [
              // Em mobile, talvez esconder o "Sou Família" da nav e deixar só no hero
              if (MediaQuery.of(context).size.width > 600)
                TextButton(
                  onPressed: () => context.pushNamed('area-beneficiario'),
                  // Rota GoRouter
                  child: const Text(
                    "Sou Família",
                    style: TextStyle(color: Color(0xFF1F2937)),
                  ),
                ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => context.go('/area-colaborador'),
                // Rota GoRouter
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                child: const Text("Sou ONG / Colaborador"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Layout Mobile (Vertical) ---
class _MobileHero extends StatelessWidget {
  const _MobileHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HeroTextContent(centerAlign: true),
        const SizedBox(height: 40),
        const _HeroImageContent(),
        const SizedBox(height: 40),
        // Ícones de Features em Mobile (Grid ou Coluna)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: const [
            _FeatureItem(
              icon: Icons.notifications_outlined,
              text: "Notificação garantida",
            ),
            _FeatureItem(
              icon: Icons.location_on_outlined,
              text: "ONGs próximas",
            ),
            _FeatureItem(
              icon: Icons.people_outline,
              text: "Coordenação inteligente",
            ),
          ],
        ),
      ],
    );
  }
}

// --- Layout Desktop (Horizontal) ---
class _DesktopHero extends StatelessWidget {
  const _DesktopHero();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Texto na esquerda (50%)
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroTextContent(centerAlign: false),
              const SizedBox(height: 48),
              Row(
                children: const [
                  _FeatureItem(
                    icon: Icons.notifications_outlined,
                    text: "Notificação garantida",
                  ),
                  SizedBox(width: 24),
                  _FeatureItem(
                    icon: Icons.location_on_outlined,
                    text: "ONGs próximas",
                  ),
                  SizedBox(width: 24),
                  _FeatureItem(
                    icon: Icons.people_outline,
                    text: "Coordenação inteligente",
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
        // Imagem na direita (50%)
        const Expanded(flex: 6, child: _HeroImageContent()),
      ],
    );
  }
}

// --- Conteúdo de Texto Reutilizável ---
class _HeroTextContent extends StatelessWidget {
  final bool centerAlign;

  const _HeroTextContent({required this.centerAlign});

  @override
  Widget build(BuildContext context) {
    final align = centerAlign ? TextAlign.center : TextAlign.start;
    final crossAlign = centerAlign
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED), // Laranja bem clarinho
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFEDD5)),
          ),
          child: Text(
            "Retirada Garantida",
            style: GoogleFonts.inter(
              color: const Color(0xFFC2410C),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Comida fresca,\nquando você precisa",
          textAlign: align,
          style: GoogleFonts.inter(
            fontSize: centerAlign ? 42 : 56, // Menor no mobile
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Chega de viagens perdidas. O Prato Certo conecta você às ONGs com alimentos disponíveis, notificando apenas quando a retirada está garantida.",
          textAlign: align,
          style: GoogleFonts.inter(
            fontSize: 18,
            height: 1.5,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 32),
        // Botões de Ação Principal
        Wrap(
          alignment: centerAlign ? WrapAlignment.center : WrapAlignment.start,
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/cadastro-familia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Cadastrar Família →",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            OutlinedButton(
              onPressed: () => context.go('/mapa-ongs'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Ver Mapa de ONGs",
                style: TextStyle(fontSize: 16, color: Color(0xFF374151)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- Componente de Imagem com Card Flutuante ---
class _HeroImageContent extends StatelessWidget {
  const _HeroImageContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagem Principal (Arredondada)
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            // Usei uma imagem Unsplash de vegetais como placeholder
            'assets/imgs/hero_food.jpg',
            fit: BoxFit.cover,
            height: 400,
            width: double.infinity,
          ),
        ),
        // Card Flutuante (+2.500 Famílias)
        Positioned(
          bottom: 24,
          left: 24,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981), // Verde sucesso
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "+2.500",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Famílias atendidas",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Item de Feature Pequeno ---
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 20), // Ícone Verde
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            color: const Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
