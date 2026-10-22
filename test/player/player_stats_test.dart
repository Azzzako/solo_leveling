import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling/src/features/player/domain/player_stats.dart';

void main() {
  group('PlayerStats level curve', () {
    test('xp 0 corresponde al nivel 1 sin progreso acumulado', () {
      final stats = PlayerStats(name: 'A', totalXp: 0, streak: 0);

      expect(stats.level, 1);
      expect(stats.xpIntoLevel, 0);
      expect(stats.levelProgress, 0);
    });

    test('el primer nivel pide 200 XP', () {
      expect(PlayerStats.xpToNext(1), 200);
      expect(PlayerStats.xpToNext(10), 875);
      expect(PlayerStats.xpToNext(50), 3875);
    });

    test('acumula niveles al sumar XP', () {
      final stats = PlayerStats(
        name: 'A',
        totalXp: PlayerStats.totalXpForLevel(2),
        streak: 0,
      );

      expect(stats.level, 2);
      expect(stats.xpIntoLevel, 0);
    });

    test('el progreso del nivel es una fracción entre 0 y 1', () {
      final base = PlayerStats.totalXpForLevel(3);
      final stats = PlayerStats(name: 'A', totalXp: base + 150, streak: 0);

      expect(stats.level, 3);
      expect(stats.xpIntoLevel, 150);
      expect(stats.xpNeededForNext, 350);
      expect(stats.levelProgress, closeTo(0.4286, 0.001));
    });

    test('un día completo no sube más de un nivel', () {
      const dailyXp = 270;
      final stats = PlayerStats(name: 'A', totalXp: dailyXp, streak: 0);

      expect(stats.level, 2);
      expect(stats.xpIntoLevel, 70);
    });

    test('el ascenso es lento: C hasta el 13, S hasta el 44', () {
      expect(HunterRank.fromLevel(13), HunterRank.c);
      expect(HunterRank.fromLevel(21), HunterRank.b);
      expect(HunterRank.fromLevel(31), HunterRank.a);
      expect(HunterRank.fromLevel(44), HunterRank.s);

      final rankBLevel = PlayerStats.totalXpForLevel(14);
      final rankSLevel = PlayerStats.totalXpForLevel(45);
      const dailyXp = 270;

      expect((rankBLevel / dailyXp).round(), greaterThanOrEqualTo(30));
      expect((rankSLevel / dailyXp).round(), greaterThan(250));
    });
  });

  group('HunterRank', () {
    test('mapea niveles a rangos', () {
      expect(HunterRank.fromLevel(1), HunterRank.e);
      expect(HunterRank.fromLevel(7), HunterRank.d);
      expect(HunterRank.fromLevel(12), HunterRank.c);
      expect(HunterRank.fromLevel(18), HunterRank.b);
      expect(HunterRank.fromLevel(25), HunterRank.a);
      expect(HunterRank.fromLevel(40), HunterRank.s);
      expect(HunterRank.fromLevel(55), HunterRank.ss);
      expect(HunterRank.fromLevel(100), HunterRank.sss);
    });

    test('todos los rangos tienen etiqueta y título', () {
      for (final rank in HunterRank.values) {
        expect(rank.label, isNotEmpty);
        expect(rank.title, isNotEmpty);
      }
    });
  });

  group('streak', () {
    final monday = DateTime(2026, 10, 19, 21);
    final tuesday = DateTime(2026, 10, 20, 7);
    final wednesday = DateTime(2026, 10, 21, 23);

    test('primer completado arranca el streak en 1', () {
      expect(
        PlayerStats.streakAfterCompletion(
          currentStreak: 0,
          today: monday,
          lastCompletion: null,
        ),
        1,
      );
    });

    test('varias misiones el mismo día no suben el streak', () {
      expect(
        PlayerStats.streakAfterCompletion(
          currentStreak: 3,
          today: monday,
          lastCompletion: DateTime(2026, 10, 19, 8),
        ),
        3,
      );
    });

    test('día consecutivo lo incrementa', () {
      expect(
        PlayerStats.streakAfterCompletion(
          currentStreak: 3,
          today: tuesday,
          lastCompletion: monday,
        ),
        4,
      );
    });

    test('día fallido reinicia el streak', () {
      expect(
        PlayerStats.streakAfterCompletion(
          currentStreak: 9,
          today: wednesday,
          lastCompletion: monday,
        ),
        1,
      );
    });
  });
}
