import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Colors } from '@/constants/colors';
import { useAppFonts } from '@/hooks/use-fonts';

// TODO: definir regra de pontuação e bonificação no código com o time de produto
interface LoyaltyCardProps {
  currentPoints?: number;
  targetPoints?: number;
  rewardDescription?: string;
}

export function LoyaltyCard({
  currentPoints = 0,
  targetPoints = 10,
  rewardDescription = '1 Corte Grátis ou Tratos VIP',
}: LoyaltyCardProps) {
  const { fontRegular, fontSemiBold, fontBold } = useAppFonts();

  // TODO: definir regra de pontuação e bonificação no código
  const progressPercentage = Math.min(Math.max((currentPoints / targetPoints) * 100, 0), 100);

  return (
    <LinearGradient
      colors={[Colors.gold, Colors.goldDark]}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
      style={styles.card}>
      <View style={styles.headerRow}>
        <View style={styles.tagBadge}>
          <Text style={[styles.tagText, { fontFamily: fontSemiBold }]}>PROGRAMA FIDELIDADE</Text>
        </View>
        <Text style={[styles.pointsBadge, { fontFamily: fontBold }]}>
          {currentPoints}/{targetPoints} pts
        </Text>
      </View>

      <Text style={[styles.title, { fontFamily: fontBold }]}>Seus Pontos de Fidelidade</Text>
      <Text style={[styles.subtitle, { fontFamily: fontRegular }]}>
        {currentPoints > 0
          ? `Faltam ${Math.max(targetPoints - currentPoints, 0)} atendimentos para você resgatar: ${rewardDescription}`
          : `Realize atendimentos para acumular pontos e resgatar: ${rewardDescription}`}
      </Text>

      {/* Progress Bar */}
      <View style={styles.progressBackground}>
        <View style={[styles.progressFill, { width: `${progressPercentage}%` }]} />
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 16,
    padding: 20,
    gap: 8,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  tagBadge: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 8,
  },
  tagText: {
    color: Colors.white,
    fontSize: 10,
    letterSpacing: 0.5,
  },
  pointsBadge: {
    color: Colors.white,
    fontSize: 14,
  },
  title: {
    color: Colors.white,
    fontSize: 18,
    marginTop: 4,
  },
  subtitle: {
    color: Colors.white,
    fontSize: 13,
    opacity: 0.9,
    lineHeight: 18,
  },
  progressBackground: {
    height: 8,
    backgroundColor: 'rgba(255,255,255,0.3)',
    borderRadius: 4,
    marginTop: 8,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: Colors.white,
    borderRadius: 4,
  },
});
