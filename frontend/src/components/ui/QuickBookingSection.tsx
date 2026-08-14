import React from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { Colors } from '@/constants/colors';
import { useAppFonts } from '@/hooks/use-fonts';
import type { ProfessionalMin } from '@/services/professionalServices';

interface QuickBookingSectionProps {
  professionals: ProfessionalMin[];
  selectedProfessionalId: string | null;
  onSelectProfessional: (id: string | null) => void;
  onStartBooking: () => void;
}

export function QuickBookingSection({
  professionals,
  selectedProfessionalId,
  onSelectProfessional,
  onStartBooking,
}: QuickBookingSectionProps) {
  const { fontRegular, fontSemiBold } = useAppFonts();

  const selectedName = selectedProfessionalId
    ? professionals.find((p) => p.id === selectedProfessionalId)?.name || 'Profissional'
    : 'Qualquer Profissional';

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={[styles.title, { fontFamily: fontSemiBold }]}>Agendamento Rápido</Text>
        <Text style={[styles.subtitle, { fontFamily: fontRegular }]}>
          Escolha o profissional e veja os horários disponíveis
        </Text>
      </View>

      {/* Seletor de Profissionais */}
      {professionals.length === 0 ? (
        <View style={styles.emptyBox}>
          <Text style={[styles.emptyText, { fontFamily: fontRegular }]}>
            Nenhum profissional cadastrado no momento.
          </Text>
        </View>
      ) : (
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.professionalsRow}>
          <TouchableOpacity
            style={[
              styles.chip,
              selectedProfessionalId === null && styles.chipSelected,
            ]}
            onPress={() => onSelectProfessional(null)}
            activeOpacity={0.8}>
            <View
              style={[
                styles.avatarPlaceholder,
                selectedProfessionalId === null && styles.avatarSelected,
              ]}>
              <Text style={{ fontSize: 16 }}>⭐</Text>
            </View>
            <Text
              style={[
                styles.chipText,
                { fontFamily: fontSemiBold },
                selectedProfessionalId === null && styles.chipTextSelected,
              ]}>
              Qualquer Profissional
            </Text>
          </TouchableOpacity>

          {professionals.map((prof) => {
            const isSelected = selectedProfessionalId === prof.id;
            return (
              <TouchableOpacity
                key={prof.id}
                style={[styles.chip, isSelected && styles.chipSelected]}
                onPress={() => onSelectProfessional(prof.id)}
                activeOpacity={0.8}>
                <View style={[styles.avatarPlaceholder, isSelected && styles.avatarSelected]}>
                  <Text style={{ fontSize: 16 }}>👤</Text>
                </View>
                <Text
                  style={[
                    styles.chipText,
                    { fontFamily: fontSemiBold },
                    isSelected && styles.chipTextSelected,
                  ]}>
                  {prof.name}
                </Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      )}

      {/* Botão de Ação */}
      <TouchableOpacity
        style={[styles.actionButton, professionals.length === 0 && { opacity: 0.7 }]}
        onPress={onStartBooking}
        activeOpacity={0.85}>
        <Text style={[styles.actionButtonText, { fontFamily: fontSemiBold }]}>
          {professionals.length === 0 ? 'Iniciar Agendamento' : `Agendar com ${selectedName}`}
        </Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: Colors.surface,
    borderRadius: 16,
    padding: 16,
    gap: 14,
  },
  header: {
    gap: 2,
  },
  title: {
    color: Colors.dark,
    fontSize: 16,
  },
  subtitle: {
    color: Colors.grey400,
    fontSize: 13,
  },
  emptyBox: {
    paddingVertical: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  emptyText: {
    color: Colors.grey400,
    fontSize: 13,
  },
  professionalsRow: {
    gap: 10,
    paddingVertical: 4,
  },
  chip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    backgroundColor: Colors.white,
    borderWidth: 1.5,
    borderColor: Colors.grey100,
    borderRadius: 24,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  chipSelected: {
    borderColor: Colors.gold,
    backgroundColor: Colors.goldLight,
  },
  avatarPlaceholder: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: Colors.surface,
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatarSelected: {
    backgroundColor: Colors.white,
  },
  chipText: {
    color: Colors.grey500,
    fontSize: 13,
  },
  chipTextSelected: {
    color: Colors.gold,
  },
  actionButton: {
    backgroundColor: Colors.gold,
    borderRadius: 12,
    paddingVertical: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  actionButtonText: {
    color: Colors.white,
    fontSize: 14,
  },
});
