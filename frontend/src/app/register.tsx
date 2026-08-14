import { Image } from 'expo-image';
import { useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useState } from 'react';
import { KeyboardAvoidingView, Platform, ScrollView, StyleSheet, Text, TouchableOpacity, View, Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Button } from '@/components/ui/Button';
import { InputField } from '@/components/ui/InputField';
import { Colors } from '@/constants/colors';
import { useAppFonts } from '@/hooks/use-fonts';
import { register as registerService } from '@/services/authServices';
import { RegisterSchema } from '@/schemas/authSchemas';
import { formatPhone } from '@/utils/formatters';

export default function RegisterScreen() {
  const { fontRegular, fontSemiBold } = useAppFonts();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [dateOfBirth, setDateOfBirth] = useState('');
  const [password, setPassword] = useState('');
  
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [globalError, setGlobalError] = useState('');


  function handleDateChange(text: string) {
    const cleaned = text.replace(/\D/g, '');
    let formatted = cleaned;
    if (cleaned.length > 2 && cleaned.length <= 4) {
      formatted = `${cleaned.slice(0, 2)}/${cleaned.slice(2)}`;
    } else if (cleaned.length > 4) {
      formatted = `${cleaned.slice(0, 2)}/${cleaned.slice(2, 4)}/${cleaned.slice(4, 8)}`;
    }
    setDateOfBirth(formatted);
  }

  function convertDateToISO(dateStr: string): string | undefined {
    if (!dateStr || dateStr.length < 10) return undefined;
    const [day, month, year] = dateStr.split('/');
    return `${year}-${month}-${day}`;
  }


  async function handleRegister() {
    setGlobalError('');
    setErrors({});


    const formattedDate = convertDateToISO(dateOfBirth);

    const parseResult = RegisterSchema.safeParse({ name, email, phone, password, dateOfBirth: formattedDate });
    if (!parseResult.success) {
      const fieldErrors: Record<string, string> = {};
      parseResult.error.issues.forEach(issue => {
        const field = issue.path[0] as string;
        if (!fieldErrors[field]) fieldErrors[field] = issue.message;
      });
      setErrors(fieldErrors);
      return;
    }
    
    try {
      setIsSubmitting(true);
      const formattedDate = convertDateToISO(dateOfBirth);
      await registerService(name, email, password, 'CUSTOMER',phone,formattedDate);
      router.replace('/login');
    } catch (err: any) {
      setGlobalError(err?.response?.data?.message || 'Erro ao criar conta. Tente novamente.');
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <StatusBar style="dark" />
      <ScrollView
        contentContainerStyle={[styles.scroll, { paddingTop: insets.top + 16, paddingBottom: insets.bottom + 24 }]}
        showsVerticalScrollIndicator={false}
        keyboardShouldPersistTaps="handled">

        <Image
          source={{ uri: 'https://api.builder.io/api/v1/image/assets/TEMP/b6498689774337ed760cfa4c9fc86c77834936e1?width=300' }}
          style={styles.logo}
          contentFit="contain"
        />

        <View style={styles.header}>
          <Text style={[styles.title, { fontFamily: fontSemiBold }]}>Criar Nova Conta</Text>
          <Text style={[styles.subtitle, { fontFamily: fontRegular }]}>Preencha seus dados para se cadastrar</Text>
        </View>

        <View style={styles.form}>
          <InputField label="Nome completo" value={name} onChangeText={setName} placeholder="Seu nome completo" autoCapitalize="words" error={errors.name} />
          <InputField label="Email" value={email} onChangeText={setEmail} placeholder="seu@email.com" keyboardType="email-address" autoCapitalize="none" error={errors.email} />
          <InputField label="Número de telefone" value={phone} onChangeText={(text) => setPhone(formatPhone(text))} placeholder="(00) 00000-0000" keyboardType="phone-pad" error={errors.phone} />
          <InputField label="Data de nascimento" value={dateOfBirth} onChangeText={handleDateChange} placeholder="DD/MM/AAAA" keyboardType="numeric"  maxLength={10}error={errors.dateOfBirth} />
          <InputField label="Senha" value={password} onChangeText={setPassword} placeholder="••••••••••••" secureTextEntry error={errors.password} />
        </View>

        {globalError ? <Text style={styles.errorText}>{globalError}</Text> : null}

        <Button label={isSubmitting ? "Criando..." : "Criar conta"} onPress={handleRegister} disabled={isSubmitting} />

        <View style={styles.loginRow}>
          <Text style={[styles.loginText, { fontFamily: fontRegular }]}>Já tem uma conta? </Text>
          <TouchableOpacity onPress={() => router.push('/login')}>
            <Text style={[styles.loginLink, { fontFamily: fontSemiBold }]}>Entrar</Text>
          </TouchableOpacity>
        </View>

      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.white },
  scroll: { paddingHorizontal: 25, alignItems: 'center', gap: 24 },
  logo: { width: 150, height: 124 },
  header: { alignSelf: 'stretch', gap: 8 },
  title: { color: Colors.dark, fontSize: 24, lineHeight: 36, fontWeight: '600' },
  subtitle: { color: Colors.grey400, fontSize: 14, lineHeight: 21.7, letterSpacing: -0.28 },
  form: { alignSelf: 'stretch', gap: 16 },
  loginRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center' },
  loginText: { color: Colors.grey400, fontSize: 14, lineHeight: 21.7, letterSpacing: -0.28 },
  loginLink: { color: Colors.gold, fontSize: 14, lineHeight: 21.7, letterSpacing: -0.28, fontWeight: '600' },
  errorText: { color: Colors.error, fontSize: 14, textAlign: 'center', marginTop: 8,fontWeight:'bold' },
});
