import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/diagnostics.dart';
import '../../core/services/haptics.dart';
import '../../data/db/database.dart';
import '../dashboard/dashboard_state.dart';
import '../shared/widgets/glass_card.dart';

/// Live in-app log + repair tools so we can debug issues without a USB cable.
class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Subscribe to log revisions so the list updates live.
    ref.watch(wxLogRevisionProvider);
    final entries = WxLog.snapshot().reversed.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Copy log',
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: () {
              final text = entries
                  .map((e) =>
                      '${DateFormat.Hms().format(e.at)}  ${e.level.name.toUpperCase().padRight(5)}  ${e.tag}: ${e.message}')
                  .join('\n');
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Log copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              WxLog.clear();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
        children: <Widget>[
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'REPAIR TOOLS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textMuted,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Force re-ingest now'),
                  onPressed: () async {
                    Haptics.tap();
                    WxLog.info('repair', 'manual re-ingest requested');
                    await runBackgroundIngest(ref, force: true);
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: const Text('Wipe stats DB & re-ingest'),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Wipe statistics?'),
                        content: const Text(
                          'Clears all per-day usage rows in the database. '
                          'Settings, achievements, and focus history are kept. '
                          'A fresh ingest will run after.',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Wipe'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      Haptics.success();
                      final db = ref.read(dbProvider);
                      WxLog.warn('repair', 'wiping aggregates / hours / phone');
                      try {
                        await db.delete(db.dailyAggregates).go();
                        await db.delete(db.hourBuckets).go();
                        await db.delete(db.dailyPhone).go();
                        await db.delete(db.usageEvents).go();
                        await db.delete(db.notificationsTable).go();
                        WxLog.info('repair', 'wipe complete');
                      } catch (e, st) {
                        WxLog.error('repair', 'wipe failed', e, st);
                      }
                      // Force fresh ingest after wipe.
                      if (context.mounted) {
                        await runBackgroundIngest(ref, force: true);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'LIVE LOG',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: WxColors.textMuted,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            const GlassCard(
              child: Text(
                'No log entries yet.',
                style: TextStyle(color: WxColors.textSecondary),
              ),
            )
          else
            ...entries.map((e) => _LogTile(entry: e)),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});
  final WxLogEntry entry;

  Color get _accent {
    switch (entry.level) {
      case WxLogLevel.info:
        return WxColors.cyan;
      case WxLogLevel.warn:
        return WxColors.amber;
      case WxLogLevel.error:
        return WxColors.crimson;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: WxColors.surface1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _accent.withValues(alpha: 0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 6, right: 8),
              decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        DateFormat.Hms().format(entry.at),
                        style: WxTypography.mono(
                          size: 11,
                          color: WxColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.tag,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: WxColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
