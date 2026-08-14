import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { LocationPinIcon, PlusIcon } from '@/components/icons';
import { Colors } from '@/constants/colors';
import { useAppFonts } from '@/hooks/use-fonts';
import type { Booking } from '@/services/bookingServices';

interface NextBookingCardProps {
  booking: Booking | null;
  onNewBookingPress: () => void;
}

export function NextBookingCard({ booking, onNewBookingPress }: NextBookingCardProps) {
  const { fontRegular, fontSemiBold, fontBold } = useAppFonts();

  if (!booking) {
    return (
      <View style={styles.emptyContainer}>
        <View style={styles.emptyIconCircle}>
          <Text style={styles.emptyIconText}>📅</Text>
        </View>
        <Text style={[styles.emptyTitle, { fontFamily: fontSemiBold }]}>
          Nenhum agendamento marcado
        </Text>
        <Text style={[styles.emptySubtitle, { fontFamily: fontRegular }]}>
          Que tal agendar seu horário com praticidade?
        </Text>
        <TouchableOpacity style={styles.emptyButton} onPress={onNewBookingPress} activeOpacity={0.85}>
          <PlusIcon size={16} color={Colors.white} />
          <Text style={[styles.emptyButtonText, { fontFamily: fontSemiBold }]}>
            Agendar Horário
          </Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.card}>
      <View style={styles.topRow}>
        <Text style={[styles.dateText, { fontFamily: fontSemiBold }]}>{booking.date}</Text>
        <View style={styles.statusBadge}>
          <Text style={[styles.statusText, { fontFamily: fontSemiBold }]}>Confirmado</Text>
        </View>
      </View>

      <View style={styles.bodyRow}>
        <View style={styles.avatarBox}>
          <Text style={{ fontSize: 20 }}>✂️</Text>
        </View>
        <View style={styles.infoBox}>
          <Text style={[styles.shopName, { fontFamily: fontSemiBold }]}>{booking.shop}</Text>
          <View style={styles.addrRow}>
            <LocationPinIcon size={12} />
            <Text style={[styles.addrText, { fontFamily: fontRegular }]} numberOfLines={1}>
              {booking.address}
            </Text>
          </View>
          <Text style={[styles.servicesText, { fontFamily: fontRegular }]} numberOfLines={1}>
            {booking.services}
          </Text>
        </View>
        <Text style={[styles.priceText, { fontFamily: fontBold }]}>{booking.price}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: Colors.surface,
    borderRadius: 16,
    padding: 16,
    gap: 12,
  },
  topRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  dateText: {
    color: Colors.dark,
    fontSize: 14,
  },
  statusBadge: {
    backgroundColor: Colors.goldLight,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 8,
  },
  statusText: {
    color: Colors.gold,
    fontSize: 12,
  },
  bodyRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  avatarBox: {
    width: 48,
    height: 48,
    borderRadius: 12,
    backgroundColor: Colors.white,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: Colors.grey100,
  },
  infoBox: {
    flex: 1,
    gap: 2,
  },
  shopName: {
    color: Colors.dark,
    fontSize: 15,
  },
  addrRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  addrText: {
    color: Colors.grey400,
    fontSize: 12,
    flex: 1,
  },
  servicesText: {
    color: Colors.grey500,
    fontSize: 12,
    marginTop: 2,
  },
  priceText: {
    color: Colors.gold,
    fontSize: 15,
  },

  // Empty State Styles (utilizando somente Colors do projeto)
  emptyContainer: {
    backgroundColor: Colors.surface,
    borderRadius: 16,
    padding: 24,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  emptyIconCircle: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: Colors.goldLight,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 4,
  },
  emptyIconText: {
    fontSize: 22,
  },
  emptyTitle: {
    color: Colors.dark,
    fontSize: 15,
  },
  emptySubtitle: {
    color: Colors.grey400,
    fontSize: 13,
    textAlign: 'center',
    marginBottom: 8,
  },
  emptyButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Colors.gold,
    borderRadius: 10,
    paddingVertical: 10,
    paddingHorizontal: 18,
    gap: 6,
  },
  emptyButtonText: {
    color: Colors.white,
    fontSize: 13,
  },
});
