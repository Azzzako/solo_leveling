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

    test('la curva exige 325 XP en el primer nivel y crece 122 por nivel', () {
      expect(PlayerStats.xpToNext(1), 325);
      expect(PlayerStats.xpToNext(10), 1423);
      expect(PlayerStats.xpToNext(50), 6303);
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
      final stats = PlayerStats(name: 'A', totalXp: base + 240, streak: 0);

      expect(stats.level, 3);
      expect(stats.xpIntoLevel, 240);
      expect(stats.xpNeededForNext, 569);
      expect(stats.levelProgress, closeTo(0.4217, 0.001));
    });

    test('un día completo (440 XP) sube un nivel y deja progreso', () {
      const dailyXp = 440;
      final stats = PlayerStats(name: 'A', totalXp: dailyXp, streak: 0);

      expect(stats.level, 2);
      expect(stats.xpIntoLevel, 115);
    });

    test('el ascenso es lento: C en un mes, S en diez meses', () {
      expect(HunterRank.fromLevel(13), HunterRank.c);
      expect(HunterRank.fromLevel(21), HunterRank.b);
      expect(HunterRank.fromLevel(31), HunterRank.a);
      expect(HunterRank.fromLevel(44), HunterRank.s);

      const dailyXp = 440;
      final rankCLevel = PlayerStats.totalXpForLevel(14);
      final rankSLevel = PlayerStats.totalXpForLevel(45);

      expect((rankCLevel / dailyXp).round(), inInclusiveRange(28, 34));
      expect((rankSLevel / dailyXp).round(), inInclusiveRange(285, 300));
    });

    test('con XP negativo se queda en nivel 1 con deuda', () {
      final stats = PlayerStats(name: 'A', totalXp: -900, streak: 3);

      expect(stats.level, 1);
      expect(stats.inDebt, isTrue);
      expect(stats.xpIntoLevel, -900);
      expect(stats.rank, HunterRank.e);
      expect(PlayerStats.levelForXp(-1), 1);
      expect(PlayerStats.levelForXp(0), 1);
    });

    test('recuperar la deuda devuelve al nivel 1 sin progreso falso', () {
      final inDebt = PlayerStats(name: 'A', totalXp: -500, streak: 1);
      final recovered = PlayerStats(name: 'A', totalXp: 100, streak: 1);

      expect(inDebt.level, 1);
      expect(inDebt.inDebt, isTrue);
      expect(recovered.level, 1);
      expect(recovered.inDebt, isFalse);
      expect(recovered.xpIntoLevel, 100);
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
