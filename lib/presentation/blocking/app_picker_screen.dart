import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../core/services/native_bridge.dart';
import '../../data/repositories/blocking_repository.dart';
import '../../domain/models/app_category.dart';

class _AppRow {
  final String packageName;
  final String displayName;
  final AppCategory category;
  const _AppRow(this.packageName, this.displayName, this.category);
}

final _installedAppsProvider = FutureProvider<List<_AppRow>>((ref) async {
  final list = await ref.watch(nativeBridgeProvider).listInstalledApps();
  final out = list.map((m) {
    final pkg = m['packageName'] as String? ?? '';
    final name = (m['displayName'] as String?) ?? pkg;
    final code = m['category'] as String?;
    final cat = AppCategory.fromCode(code) == AppCategory.other
        ? CategoryHeuristics.classify(pkg, name)
        : AppCategory.fromCode(code);
    return _AppRow(pkg, name, cat);
  }).toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));
  return out;
});

class AppPickerScreen extends ConsumerStatefulWidget {
  const AppPickerScreen({super.key});
  @override
  ConsumerState<AppPickerScreen> createState() => _AppPickerScreenState();
}

class _AppPickerScreenState extends ConsumerState<AppPickerScreen> {
  String _q = '';
  String _mode = 'soft';
  Duration? _duration;
  final Set<String> _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final apps = ref.watch(_installedAppsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick apps'),
        actions: <Widget>[
          TextButton(
            onPressed: _selected.isEmpty ? null : _saveAll,
            child: Text(
              _selected.isEmpty ? 'Save' : 'Save (${_selected.length})',
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search apps',
                filled: true,
                fillColor: WxColors.surface1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          _BlockSettings(
            mode: _mode,
            duration: _duration,
            onMode: (m) => setState(() => _mode = m),
            onDuration: (d) => setState(() => _duration = d),
          ),
          Expanded(
            child: apps.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (rows) {
                final filtered = _q.isEmpty
                    ? rows
                    : rows
                        .where((r) =>
                            r.displayName.toLowerCase().contains(_q) ||
                            r.packageName.toLowerCase().contains(_q))
                        .toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No apps found.',
                        style: TextStyle(color: WxColors.textSecondary)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final r = filtered[i];
                    final on = _selected.contains(r.packageName);
                    final color =
                        WxColors.category[r.category.code] ?? WxColors.accent;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() {
                          if (on) {
                            _selected.remove(r.packageName);
                          } else {
                            _selected.add(r.packageName);
                          }
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  r.displayName.isEmpty
                                      ? '?'
                                      : r.displayName[0],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(r.displayName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: WxColors.textPrimary,
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 2),
                                    Text(r.packageName,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: WxColors.textMuted)),
                                  ],
                                ),
                              ),
                              Checkbox(
                                value: on,
                                onChanged: (_) => setState(() {
                                  if (on) {
                                    _selected.remove(r.packageName);
                                  } else {
                                    _selected.add(r.packageName);
                                  }
                                }),
                                activeColor: WxColors.accent,
                                checkColor: WxColors.void_,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAll() async {
    final repo = ref.read(blockingRepositoryProvider);
    final until =
        _duration == null ? null : DateTime.now().add(_duration!);
    await Future.wait(_selected.map((pkg) =>
        repo.setRule(packageName: pkg, mode: _mode, until: until)));
    if (!mounted) return;
    ref.invalidate(activeBlockRulesProvider);
    context.pop();
  }
}

class _BlockSettings extends StatelessWidget {
  const _BlockSettings({
    required this.mode,
    required this.duration,
    required this.onMode,
    required this.onDuration,
  });
  final String mode;
  final Duration? duration;
  final ValueChanged<String> onMode;
  final ValueChanged<Duration?> onDuration;

  static const List<({String code, String label})> _modes = <({String code, String label})>[
    (code: 'soft', label: 'Soft'),
    (code: 'hard', label: 'Hard'),
    (code: 'extreme', label: 'Extreme'),
  ];
  static const List<({Duration? d, String label})> _durations = <({Duration? d, String label})>[
    (d: Duration(minutes: 30), label: '30m'),
    (d: Duration(hours: 1), label: '1h'),
    (d: Duration(hours: 4), label: '4h'),
    (d: Duration(hours: 12), label: '12h'),
    (d: null, label: 'Always'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('MODE',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: WxColors.textMuted,
                letterSpacing: 1.4,
              )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <Widget>[
              for (final m in _modes)
                ChoiceChip(
                  label: Text(m.label),
                  selected: mode == m.code,
                  onSelected: (_) => onMode(m.code),
                  selectedColor: WxColors.accent,
                  backgroundColor: WxColors.surface2,
                  side: const BorderSide(color: WxColors.hairline),
                  labelStyle: TextStyle(
                    color: mode == m.code
                        ? WxColors.void_
                        : WxColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('DURATION',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: WxColors.textMuted,
                letterSpacing: 1.4,
              )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <Widget>[
              for (final dr in _durations)
                ChoiceChip(
                  label: Text(dr.label),
                  selected: duration == dr.d,
                  onSelected: (_) => onDuration(dr.d),
                  selectedColor: WxColors.cyan,
                  backgroundColor: WxColors.surface2,
                  side: const BorderSide(color: WxColors.hairline),
                  labelStyle: TextStyle(
                    color: duration == dr.d
                        ? WxColors.void_
                        : WxColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
