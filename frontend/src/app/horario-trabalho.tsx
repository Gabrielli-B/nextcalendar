import { useRouter } from 'expo-router';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Svg, { Circle, Path } from 'react-native-svg';
import { ArrowRightIcon, ChevronLeftIcon } from '@/components/icons';
import { Colors } from '@/constants/colors';
import { useAppFonts } from '@/hooks/use-fonts';

// Ícone de informação (InfoIcon)
function InfoIcon({ color = Colors.gold, size = 20 }: { color?: string; size?: number }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={12} r={10} stroke={color} strokeWidth={2} />
      <Path d="M12 16v-4" stroke={color} strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
      <Circle cx={12} cy={8} r={1.5} fill={color} />
    </Svg>
  );
}

const SCHEDULE_DAYS = [
  { id: '1', day: 'Segunda-feira', hours: '08:00 - 12:00 | 13:30 - 18:00' },
  { id: '2', day: 'Terça-feira', hours: '08:00 - 12:00 | 13:30 - 18:00' },
  { id: '3', day: 'Quarta-feira', hours: '10:00 - 12:00 | 13:30 - 20:00' },
  { id: '4', day: 'Quinta-feira', hours: '10:00 - 12:00 | 13:30 - 20:00' },
  { id: '5', day: 'Sexta', hours: '10:00 - 12:00 | 13:30 - 20:00' },
];

export default function HorarioTrabalhoScreen() {
  const { fontRegular, fontSemiBold, fontBold } = useAppFonts();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  return (
    <View style={[styles.root, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
          <ChevronLeftIcon size={24} color={Colors.dark} />
        </TouchableOpacity>
        <Text style={[styles.headerTitle, { fontFamily: fontBold }]}>Horário de Trabalho</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        {/* Info Box */}
        <View style={styles.infoBox}>
          <InfoIcon size={20} color={Colors.gold} />
          {/* Espaço para texto informativo, caso necessário */}
        </View>

        {/* Schedule List */}
        <View style={styles.scheduleList}>
          {SCHEDULE_DAYS.map((item) => (
            <TouchableOpacity key={item.id} style={styles.scheduleCard}>
              <View>
                <Text style={[styles.dayText, { fontFamily: fontSemiBold }]}>{item.day}</Text>
                <Text style={[styles.hoursText, { fontFamily: fontRegular }]}>{item.hours}</Text>
              </View>
              <ArrowRightIcon size={20} color={Colors.grey500} />
            </TouchableOpacity>
          ))}
        </View>
      </ScrollView>
      
      {/* Footer Button */}
      <View style={styles.footer}>
        <TouchableOpacity style={styles.primaryButton}>
          <Text style={[styles.primaryButtonText, { fontFamily: fontBold }]}>Editar horários</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: Colors.white,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 16,
    gap: 16,
  },
  backButton: {
    width: 48,
    height: 48,
    borderRadius: 24,
    borderWidth: 1,
    borderColor: Colors.grey100,
    alignItems: 'center',
    justifyContent: 'center',
  },
  headerTitle: {
    fontSize: 22,
    color: Colors.dark,
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 4,
    paddingBottom: 24,
    gap: 20,
  },
  infoBox: {
    backgroundColor: '#FDF8EA', // Levemente amarelado como na imagem
    borderWidth: 1,
    borderColor: '#E8D09E',
    borderRadius: 12,
    padding: 16,
    minHeight: 64,
  },
  scheduleList: {
    gap: 12,
  },
  scheduleCard: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: Colors.white,
    borderWidth: 1,
    borderColor: Colors.grey100,
    borderRadius: 12,
    padding: 16,
  },
  dayText: {
    fontSize: 15,
    color: Colors.dark,
    marginBottom: 6,
  },
  hoursText: {
    fontSize: 14,
    color: Colors.dark,
  },
  footer: {
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 16,
  },
  primaryButton: {
    backgroundColor: Colors.gold,
    height: 52,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primaryButtonText: {
    color: Colors.white,
    fontSize: 16,
  },
});
