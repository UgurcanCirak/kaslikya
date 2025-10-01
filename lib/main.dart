import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'isletmeler',
          builder: (context, state) => const BusinessesPage(),
        ),
        GoRoute(
          path: 'kurumsal',
          builder: (context, state) => const CorporatePage(),
        ),
        GoRoute(
          path: 'iletisim',
          builder: (context, state) => const ContactPage(),
        ),
      ],
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0C6E73),
      brightness: Brightness.light,
    );
    return MaterialApp.router(
      title: 'KAŞ Likya',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: GoogleFonts.latoTextTheme(),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1000;
    final navItems = const [
      _NavItem(label: 'Ana Sayfa', icon: Icons.home, path: '/'),
      _NavItem(label: 'İşletmeler', icon: Icons.store, path: '/isletmeler'),
      _NavItem(label: 'Kurumsal', icon: Icons.group, path: '/kurumsal'),
      _NavItem(label: 'İletişim', icon: Icons.contact_mail, path: '/iletisim'),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.teal.shade50.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          children: [
            // Modern AppBar with blur effect
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Logo image (tap to enlarge)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black54,
                            builder: (_) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Hero(
                                    tag: 'app_logo_hero',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        width: 260,
                                        height: 260,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0.0, end: 1.0),
                          child: Hero(
                            tag: 'app_logo_hero',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KAŞ Likya',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'Turizm & Madencilik',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (isWide)
                        ...navItems.map((n) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _ModernNavButton(navItem: n),
                            )),
                      if (!isWide)
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(context).openEndDrawer(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
        child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(16),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      endDrawer: isWide
          ? null
          : Drawer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Colors.white,
                    ],
                  ),
                ),
                child: ListView(
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Colors.cyan.shade600,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'KAŞ Likya',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Turizm & Madencilik',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...navItems.map((n) => ListTile(
                          leading: Icon(n.icon, color: Theme.of(context).colorScheme.primary),
                          title: Text(
                            n.label,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            context.go(n.path);
                          },
                        )),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ModernNavButton extends StatefulWidget {
  const _ModernNavButton({required this.navItem});
  final _NavItem navItem;

  @override
  State<_ModernNavButton> createState() => _ModernNavButtonState();
}

class _ModernNavButtonState extends State<_ModernNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isActive = currentPath == widget.navItem.path;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: TextButton(
          onPressed: () {
            if (GoRouterState.of(context).uri.path != widget.navItem.path) {
              context.go(widget.navItem.path);
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: isActive
                ? Theme.of(context).colorScheme.primary
                : _isHovered
                    ? Colors.grey.shade100
                    : Colors.transparent,
            foregroundColor: isActive ? Colors.white : Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            widget.navItem.label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.icon, required this.path});
  final String label;
  final IconData icon;
  final String path;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: _BackgroundSlideshow(
                assetPrefix: 'assets/images/home_bg/',
                fallbackSingleImage: 'assets/images/Kas.png',
                opacity: 0.08,
                intervalMs: 6000,
                fadeMs: 900,
              ),
            ),
          ),
          SingleChildScrollView(
      child: Column(
        children: [
            const SizedBox(height: 40),
            // Hero Section
            SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Colors.cyan.shade100.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Kaş Belediyesi Kuruluşu',
                          style: TextStyle(
                            color: Colors.teal.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Hoş Geldiniz',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 48,
                            ),
                      ),
          const SizedBox(height: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Colors.cyan.shade600,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'KAŞ Likya Turizm',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 42,
                                color: Colors.white,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
          Text(
                        'Kaş Belediyesi KAŞ Likya Turizm Ticaret Madencilik Ltd. Şti.',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Duyurular, etkinlikler ve işletmelerimizi burada bulabilirsiniz.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _AnimatedButton(
                        onPressed: () => context.go('/isletmeler'),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('İşletmelerimizi Keşfedin'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
            // Features Grid
            _FeaturesGrid(),
            const SizedBox(height: 40),
            _AnnouncementsSection(
              announcements: const [
                _Announcement(
                  title: 'JEAN MONNET Burs Programı 2026-2027 Duyurusu',
                  date: '26 Eylül 2025',
                ),
                _Announcement(
                  title: '11. Uluslararası Enerji Verimliliği Forumu',
                  date: '01 Eylül 2025',
                ),
                _Announcement(
                  title: 'T.C. İstanbul Kent Üniversitesi Duyurusu',
                  date: '18 Ağustos 2025',
                ),
              ],
              onSeeAll: () async {
                const url = 'https://www.kas.bel.tr/';
                await Clipboard.setData(const ClipboardData(text: url));
              },
            ),
            const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(
        icon: Icons.eco,
        title: 'Çevre Dostu',
        description: 'Sürdürülebilir ve doğaya saygılı hizmet',
        color: Colors.green,
      ),
      _Feature(
        icon: Icons.security,
        title: 'Güvenilir',
        description: 'Belediye güvencesiyle hizmet',
        color: Colors.blue,
      ),
      _Feature(
        icon: Icons.people,
        title: 'Halk İçin',
        description: 'Halka hizmet odaklı yaklaşım',
        color: Colors.orange,
      ),
      _Feature(
        icon: Icons.star,
        title: 'Kaliteli',
        description: 'Yüksek standartlarda hizmet',
        color: Colors.purple,
      ),
    ];

    return LayoutBuilder(
            builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: features.length,
                itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: _FeatureCard(feature: features[index]),
                );
                },
              );
            },
        );
      },
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.feature});
  final _Feature feature;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.feature.color.withOpacity(_isHovered ? 0.3 : 0.1),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.feature.color.withOpacity(0.2),
                    widget.feature.color.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.feature.icon,
                size: 36,
                color: widget.feature.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.feature.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.feature.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Announcement {
  final String title;
  final String date;
  const _Announcement({required this.title, required this.date});
}

class _AnnouncementsSection extends StatelessWidget {
  const _AnnouncementsSection({
    required this.announcements,
    required this.onSeeAll,
  });

  final List<_Announcement> announcements;
  final Future<void> Function() onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.06),
            Colors.cyan.shade100.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Duyurular',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onSeeAll,
                child: const Text('Tümünü Gör'),
              )
            ],
          ),
          const SizedBox(height: 16),
          ...announcements.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.event_note, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(
                      a.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      a.date,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  const _AnimatedButton({required this.onPressed, required this.child});
  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: _isHovered ? 12 : 6,
            shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class BusinessesPage extends StatelessWidget {
  const BusinessesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const SizedBox(height: 20),
            Text(
              'İşletmelerimiz',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          const SizedBox(height: 8),
            Text(
              'Kaş\'ın doğal güzelliklerini koruyarak hizmet sunuyoruz',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            _ModernBusinessSection(
              emoji: '☕',
              title: 'Likya Park Kafe',
              subtitle: 'Doğayla iç içe, huzurla dolu bir mola alanı.',
              description:
                  'Andifli Mahallesi\'nde, yemyeşil bir sosyal yaşam alanı olarak düzenlenen Likya Park içinde yer alan Likya Park Kafe, doğa ile iç içe, sakin ve aile dostu atmosferiyle öne çıkıyor.',
              features: const [
                'Geniş açık hava oturma alanı',
                'Kahvaltı ve sıcak-soğuk içecek servisi',
                'Sessiz ve huzurlu bir atmosfer',
                'Çocuklu aileler için ideal ortam',
                'Uygun fiyatlı, belediye güvenceli hizmet',
              ],
              extra: 'Çalışma Saatleri: 08:30 – 19:00',
              gradientColors: [Colors.teal.shade400, Colors.teal.shade600],
              assetPrefix: 'assets/images/likya_park/',
            ),
            const SizedBox(height: 40),
            _ModernBusinessSection(
              emoji: '🪨',
              title: 'Kaş Gömbe Taş Ocağı',
              subtitle: 'Belediyeye ait altyapı projelerine doğal kaynak desteği.',
              description:
                  'Kaş\'ın Gömbe bölgesinde faaliyet gösteren Kaş Gömbe Taş Ocağı, belediyenin taş, kum ve dolgu malzemesi ihtiyacını karşılamak üzere kurulmuştur.',
              features: const [
                'Yol yapım ve bakım çalışmaları için taş üretimi',
                'Alt yapı projelerine hammadde desteği',
                'Çevreye duyarlı üretim',
                'Sürdürülebilir madencilik prensipleri',
                'Yerel kalkınmaya katkı',
              ],
              gradientColors: [Colors.amber.shade400, Colors.orange.shade600],
              assetPrefix: 'assets/images/gombe_tas_ocagi/',
            ),
            const SizedBox(height: 40),
            _ModernBusinessSection(
              emoji: '🌊',
              title: 'Kaş Seyrek Çakıl Plajı',
              subtitle: 'Doğal güzellik, temiz hizmet, halk plajı konforu.',
              description:
                  'Kaş\'ın en temiz ve bakir kıyılarından biri olan Seyrek Çakıl Plajı, Kaş Likya Şirketi tarafından işletilen, doğaya saygılı ve halk odaklı bir plajdır.',
              features: const [
                'Şezlong ve şemsiye kiralama',
                'Plaj kafeteryası (soğuk içecek ve atıştırmalıklar)',
                'Tuvalet ve duş alanları',
                'Temizlik ve güvenlik belediye kontrolündedir',
                'Uygun fiyat politikası',
              ],
              gradientColors: [Colors.cyan.shade400, Colors.blue.shade600],
              assetPrefix: 'assets/images/seyrek_',
              fallbackSingleImage: 'assets/images/seyrek.png',
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Colors.cyan.shade100.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.teal, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Belediyecilikten Gelen Güven, Halk İçin Hizmet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kaş Likya Turizm Ticaret Madencilik Ltd. Şti., tüm işletmelerinde şeffaflık, hizmet kalitesi ve çevre duyarlılığı ilkesini benimser. Likya Park Kafe, Gömbe Taş Ocağı ve Seyrek Çakıl Plajı gibi farklı alanlardaki işletmeleri ile hem Kaşlılara hem de Kaş\'a gelen ziyaretçilere nitelikli, güvenilir hizmet sunmaktadır.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ModernBusinessSection extends StatefulWidget {
  const _ModernBusinessSection({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.gradientColors,
    required this.assetPrefix,
    this.extra,
    this.fallbackSingleImage,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final List<Color> gradientColors;
  final String? extra;
  final String assetPrefix;
  final String? fallbackSingleImage;

  @override
  State<_ModernBusinessSection> createState() => _ModernBusinessSectionState();
}

class _ModernBusinessSectionState extends State<_ModernBusinessSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_animation),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors[1].withOpacity(_isHovered ? 0.3 : 0.15),
                  blurRadius: _isHovered ? 30 : 15,
                  offset: Offset(0, _isHovered ? 12 : 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Image Carousel Section
                  SizedBox(
                    height: 280,
                width: double.infinity,
                    child: Stack(
                      children: [
                        _AssetCarousel(
                          assetPrefix: widget.assetPrefix,
                          fallbackSingleImage: widget.fallbackSingleImage,
                        ),
                        // Gradient Overlay
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Emoji Badge
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content Section
            Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.gradientColors.map((c) => c.withOpacity(0.2)).toList(),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: widget.gradientColors[1],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.gradientColors[0].withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: widget.gradientColors[1],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hizmetlerimiz',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.gradientColors[1],
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...widget.features.map((feature) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 6),
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: widget.gradientColors,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            feature,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        if (widget.extra != null) ...[
                          const SizedBox(height: 16),
                          Container(
              padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.gradientColors.map((c) => c.withOpacity(0.1)).toList(),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: widget.gradientColors[1],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.extra!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetCarousel extends StatefulWidget {
  const _AssetCarousel({
    required this.assetPrefix,
    this.fallbackSingleImage,
  });

  final String assetPrefix;
  final String? fallbackSingleImage;

  @override
  State<_AssetCarousel> createState() => _AssetCarouselState();
}

class _AssetCarouselState extends State<_AssetCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  List<String> _images = [];
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestJson);
      final List<String> all = manifest.keys.cast<String>().toList();
      final List<String> filtered = all
          .where((p) => p.startsWith(widget.assetPrefix))
          .where((p) =>
              p.endsWith('.png') ||
              p.endsWith('.jpg') ||
              p.endsWith('.jpeg') ||
              p.endsWith('.webp'))
          .toList()
        ..sort();

      if (filtered.isEmpty && widget.fallbackSingleImage != null) {
        filtered.add(widget.fallbackSingleImage!);
      }

      setState(() {
        _images = filtered;
      });

      if (_images.length > 1) {
        _timer = Timer.periodic(const Duration(milliseconds: 4000), (t) {
          if (!mounted) return;
          _current = (_current + 1) % _images.length;
          _controller.animateToPage(
            _current,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        });
      }
    } catch (_) {
      if (widget.fallbackSingleImage != null) {
        setState(() {
          _images = [widget.fallbackSingleImage!];
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade200,
              Colors.grey.shade300,
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: _images.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (context, index) {
            return Image.asset(
              _images[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48),
                  ),
                );
              },
            );
          },
        ),
        if (_images.length > 1)
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  _images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == _current ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _current ? Colors.white : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BackgroundSlideshow extends StatefulWidget {
  const _BackgroundSlideshow({
    required this.assetPrefix,
    required this.fallbackSingleImage,
    this.opacity = 0.08,
    this.intervalMs = 6000,
    this.fadeMs = 900,
  });

  final String assetPrefix;
  final String fallbackSingleImage;
  final double opacity;
  final int intervalMs;
  final int fadeMs;

  @override
  State<_BackgroundSlideshow> createState() => _BackgroundSlideshowState();
}

class _BackgroundSlideshowState extends State<_BackgroundSlideshow>
    with SingleTickerProviderStateMixin {
  List<String> _images = [];
  int _current = 0;
  int _next = 0;
  Timer? _timer;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.fadeMs),
    );
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestJson);
      final List<String> all = manifest.keys.cast<String>().toList();
      final List<String> filtered = all
          .where((p) => p.startsWith(widget.assetPrefix))
          .where((p) => p.endsWith('.png') || p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.webp'))
          .toList()
        ..sort();

      if (filtered.isEmpty) {
        filtered.add(widget.fallbackSingleImage);
      }

      setState(() {
        _images = filtered;
        _current = 0;
        _next = _images.length > 1 ? 1 : 0;
      });

      if (_images.length > 1) {
        _timer = Timer.periodic(Duration(milliseconds: widget.intervalMs), (t) async {
          if (!mounted) return;
          await _fadeController.forward(from: 0);
          setState(() {
            _current = _next;
            _next = (_next + 1) % _images.length;
          });
          _fadeController.reset();
        });
      }
    } catch (_) {
      setState(() {
        _images = [widget.fallbackSingleImage];
        _current = 0;
        _next = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    return Opacity(
      opacity: widget.opacity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(images[_current], fit: BoxFit.cover),
          if (images.length > 1)
            FadeTransition(
              opacity: _fadeController,
              child: Image.asset(images[_next], fit: BoxFit.cover),
            ),
        ],
      ),
    );
  }
}

class CorporatePage extends StatefulWidget {
  const CorporatePage({super.key});

  @override
  State<CorporatePage> createState() => _CorporatePageState();
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const double _lat = 36.20205974539514;
  static const double _lng = 29.64003517685688;

  String get _staticMapUrl {
    // OpenStreetMap static image via Mapbox-style tile server alternatives are limited.
    // Use Wikimedia maps tile for a simple static preview (proper attribution recommended on production).
    // Here we assemble a static image from Maps Location API (free alternatives are limited);
    // As a fallback, we show a clickable link if the image fails.
    final zoom = 16;
    final width = 800; // pixels (Flutter will fit it into layout)
    final height = 400;
    // Using OSM Static (third-party) style endpoint commonly mirrored
    return 'https://staticmap.openstreetmap.de/staticmap.php?center='
        '$_lat,$_lng&zoom=$zoom&size=${width}x$height&maptype=mapnik&markers=$_lat,$_lng,lightblue1';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            const SizedBox(height: 20),
            Text(
              'İletişim',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aşağıda şirket bilgilerimiz ve konumumuz yer almaktadır.',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.apartment, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Kaş Likya Turizm Ticaret Madencilik Ltd. Şti.',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            '+90 (___) ___ __ __',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('info@kaslikya.com'),
                              SizedBox(height: 4),
                              Text('destek@kaslikya.com'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Konum', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 2.2,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const latlng.LatLng(_lat, _lng),
                    initialZoom: 16,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.kaslikya.app',
                      retinaMode: true,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: const latlng.LatLng(_lat, _lng),
                          width: 48,
                          height: 48,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                        ),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          '© OpenStreetMap contributors',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = 'https://www.openstreetmap.org/?mlat=$_lat&mlon=$_lng#map=16/$_lat/$_lng';
                    await Clipboard.setData(ClipboardData(text: url));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harita bağlantısı kopyalandı. Tarayıcıya yapıştırabilirsiniz.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Haritada Aç'),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _CorporatePageState extends State<CorporatePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = const _Person(
      name: 'Müdür Adı',
      title: 'Şirket Müdürü',
      role: 'Genel Yönetim ve Stratejik Planlama',
    );
    final staff = const [
      _Person(
        name: 'Çalışan 1',
        title: 'Operasyon Müdürü',
        role: 'Tüm işletmelerin operasyonel yönetimi',
      ),
      _Person(
        name: 'Çalışan 2',
        title: 'Mali İşler Müdürü',
        role: 'Muhasebe ve finansal yönetim',
      ),
      _Person(
        name: 'Çalışan 3',
        title: 'İşletme Sorumlusu',
        role: 'Saha yönetimi ve koordinasyon',
      ),
    ];

    return AppShell(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Kurumsal',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yönetim kadromuz ve ekibimiz hakkında bilgiler',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Colors.cyan.shade100.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Şirket Müdürü',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ModernPersonCard(person: manager, isManager: true),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ekibimiz',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...staff.asMap().entries.map((entry) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (entry.key * 150)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ModernPersonCard(person: entry.value),
                        ),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _Person {
  const _Person({
    required this.name,
    required this.title,
    required this.role,
  });
  final String name;
  final String title;
  final String role;
}

class _ModernPersonCard extends StatefulWidget {
  const _ModernPersonCard({required this.person, this.isManager = false});
  final _Person person;
  final bool isManager;

  @override
  State<_ModernPersonCard> createState() => _ModernPersonCardState();
}

class _ModernPersonCardState extends State<_ModernPersonCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(_isHovered ? 0.2 : 0.1),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 6 : 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: widget.isManager ? 80 : 64,
                height: widget.isManager ? 80 : 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Colors.cyan.shade600,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.isManager ? Icons.star : Icons.person,
                  color: Colors.white,
                  size: widget.isManager ? 36 : 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.person.name,
                      style: TextStyle(
                        fontSize: widget.isManager ? 20 : 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.person.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.person.role,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isHovered)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}