import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/item/presentation/screens/home_screen.dart';
import 'features/item/presentation/screens/identify_screen.dart';
import 'features/item/presentation/screens/search_screen.dart';
import 'features/item/presentation/screens/item_list_screen.dart';
import 'features/item/presentation/screens/item_detail_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/identify',
      name: 'identify',
      builder: (context, state) {
        final imagePath = state.extra as String?;
        if (imagePath == null) {
          return const HomeScreen();
        }
        return IdentifyScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/items',
      name: 'items',
      builder: (context, state) => const ItemListScreen(),
    ),
    GoRoute(
      path: '/item/:id',
      name: 'item-detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '0';
        return ItemDetailScreen(itemId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64),
          const SizedBox(height: 16),
          Text('页面不存在: ${state.uri}'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('返回首页'),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '物品追踪器',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
