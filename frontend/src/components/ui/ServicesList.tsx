import React from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { Colors } from '@/constants/colors';
import { useAppFonts } from '@/hooks/use-fonts';
import type { ServiceResponse } from '@/services/serviceServices';

interface ServicesListProps {
  services: ServiceResponse[];
  onSelectService?: (service: ServiceResponse) => void;
}

export function ServicesList({ services, onSelectService }: ServicesListProps) {
  const { fontRegular, fontSemiBold, fontBold } = useAppFonts();

  if (!services || services.length === 0) {
    return (
      <View style={styles.emptyBox}>
        <Text style={[styles.emptyText, { fontFamily: fontRegular }]}>
          Nenhum serviço cadastrado no momento.
        </Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.sectionHeader}>
        <Text style={[styles.sectionTitle, { fontFamily: fontSemiBold }]}>Serviços Disponíveis</Text>
        <Text style={[styles.sectionSubtitle, { fontFamily: fontRegular }]}>
          {services.length} {services.length === 1 ? 'opção' : 'opções'} de atendimento
        </Text>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}>
        {services.map((item) => (
          <TouchableOpacity
            key={item.id || item.name}
            style={styles.card}
            activeOpacity={0.8}
            onPress={() => onSelectService && onSelectService(item)}>
            <View style={styles.categoryBadge}>
              <Text style={[styles.categoryText, { fontFamily: fontSemiBold }]}>
                {item.category || 'Geral'}
              </Text>
            </View>

            <Text style={[styles.serviceName, { fontFamily: fontSemiBold }]} numberOfLines={1}>
              {item.name}
            </Text>

            <Text style={[styles.durationText, { fontFamily: fontRegular }]}>
              ⏱️ {item.duration} min
            </Text>

            <View style={styles.footerRow}>
              <Text style={[styles.priceText, { fontFamily: fontBold }]}>
                R$ {typeof item.price === 'number' ? item.price.toFixed(2).replace('.', ',') : item.price}
              </Text>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    gap: 12,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  sectionTitle: {
    color: Colors.dark,
    fontSize: 16,
  },
  sectionSubtitle: {
    color: Colors.grey400,
    fontSize: 12,
  },
  emptyBox: {
    backgroundColor: Colors.surface,
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
  },
  emptyText: {
    color: Colors.grey400,
    fontSize: 13,
  },
  scrollContent: {
    gap: 12,
  },
  card: {
    width: 150,
    backgroundColor: Colors.surface,
    borderRadius: 14,
    padding: 14,
    gap: 6,
    justifyContent: 'space-between',
    borderWidth: 1,
    borderColor: Colors.grey100,
  },
  categoryBadge: {
    alignSelf: 'flex-start',
    backgroundColor: Colors.goldLight,
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
  },
  categoryText: {
    color: Colors.gold,
    fontSize: 10,
  },
  serviceName: {
    color: Colors.dark,
    fontSize: 14,
    marginTop: 2,
  },
  durationText: {
    color: Colors.grey400,
    fontSize: 12,
  },
  footerRow: {
    marginTop: 4,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  priceText: {
    color: Colors.dark,
    fontSize: 15,
  },
});
