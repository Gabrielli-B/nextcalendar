import { useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { ChevronLeftIcon } from '@/components/icons';
import { Button } from '@/components/ui/Button';
import { InputField } from '@/components/ui/InputField';
import { Colors } from '@/constants/colors';
import { useAppFonts } from '@/hooks/use-fonts';
import { useRouter } from 'expo-router';
import { registerEmpresa } from '@/services/authServices';
import { RegisterEmpresaSchema } from '@/schemas/authSchemas';
import { formatPhone } from '@/utils/formatters';
import { consultarCep } from '@/services/establishmentServices';
import { Link } from 'expo-router';

export default function RegisterEmpresaScreen() {
  const { fontRegular, fontSemiBold } = useAppFonts();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [globalError, setGlobalError] = useState('');
  
  const [cepLoading, setCepLoading] = useState(false);
  const [cepManual, setCepManual] = useState(false);

  // User fields
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  // Establishment fields
  const [legalName, setLegalName] = useState('');
  const [companyName, setCompanyName] = useState('');
  const [cnpj, setCnpj] = useState('');
  const [phone, setPhone] = useState('');
  const [whatsapp, setWhatsapp] = useState('');

  // Address
  const [cep, setCep] = useState('');
  const [street, setStreet] = useState('');
  const [number, setNumber] = useState('');
  const [complement, setComplement] = useState('');
  const [city, setCity] = useState('');
  const [neighborhood, setNeighborhood] = useState('');
  const [state, setState] = useState('');

  async function handleCepBlur() {
    const cepClean = cep.replace(/\D/g, '');
    if (cepClean.length !== 8) return;

    try {
      setCepLoading(true);
      setCepManual(false);
      const data = await consultarCep(cepClean);
      setStreet(data.logradouro ?? '');
      setNeighborhood(data.bairro ?? '');
      setCity(data.localidade ?? '');
      setState(data.uf ?? '');
    } catch (err: any) {
      const status = err?.response?.status;
      if (status === 422) {
        Alert.alert('CEP não encontrado', 'Verifique o CEP ou preencha o endereço manualmente.');
        setCepManual(true);
      } else {
        Alert.alert('Serviço de CEP indisponível', 'Preencha o endereço manualmente.');
        setCepManual(true);
      }
    } finally {
      setCepLoading(false);
    }
  }

  async function handleRegister() {
    setGlobalError('');
    setErrors({});

    const payload = {
      name, email, password, legalName, companyName, cnpj, phone, whatsapp,
      cep, street, number, complement, city, neighborhood, state
    };

    const parseResult = RegisterEmpresaSchema.safeParse(payload);
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
      await registerEmpresa({
        ...payload,
        role: 'MANAGER',
      });
      router.replace('/login');
    } catch (err: any) {
      setGlobalError(err?.response?.data?.message || 'Erro ao criar conta. Tente novamente.');
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <KeyboardAvoidingView style={styles.root} behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <View style={[styles.header, { paddingTop: insets.top + 12 }]}>
        <TouchableOpacity style={styles.backBtn} onPress={() => router.back()}>
          <ChevronLeftIcon size={20} color={Colors.dark} />
        </TouchableOpacity>
        <Text style={[styles.headerTitle, { fontFamily: fontSemiBold }]}>Cadastrar Empresa</Text>
        <View style={styles.backBtn} />
      </View>

      <ScrollView contentContainerStyle={[styles.form, { paddingBottom: insets.bottom + 100 }]} showsVerticalScrollIndicator={false} keyboardShouldPersistTaps="handled">
        <Text style={[styles.sectionTitle, { fontFamily: fontSemiBold }]}>Dados do Proprietário</Text>
        <InputField label="Nome completo" value={name} onChangeText={setName} placeholder="Seu nome completo" autoCapitalize="words" error={errors.name} />
        <InputField label="Email" value={email} onChangeText={setEmail} placeholder="seu@email.com" keyboardType="email-address" autoCapitalize="none" error={errors.email} />
        <InputField label="Senha" value={password} onChangeText={setPassword} placeholder="••••••••••••" secureTextEntry error={errors.password} />

        <Text style={[styles.sectionTitle, { fontFamily: fontSemiBold, marginTop: 12 }]}>Dados da Empresa</Text>
        <InputField label="Razão Social" value={legalName} onChangeText={setLegalName} placeholder="Razão Social LTDA" autoCapitalize="words" error={errors.legalName} />
        <InputField label="Nome Fantasia" value={companyName} onChangeText={setCompanyName} placeholder="Studio Vision" autoCapitalize="words" error={errors.companyName} />
        <InputField label="CPF/CNPJ" value={cnpj} onChangeText={setCnpj} placeholder="00000000000000" keyboardType="number-pad" error={errors.cnpj} />
        <InputField label="Celular" value={phone} onChangeText={(text) => setPhone(formatPhone(text))} placeholder="(99) 99999-9999" keyboardType="phone-pad" error={errors.phone} />
        <InputField label="Whatsapp" value={whatsapp} onChangeText={(text) => setWhatsapp(formatPhone(text))} placeholder="(99) 99999-9999" keyboardType="phone-pad" error={errors.whatsapp} />

        <Text style={[styles.sectionTitle, { fontFamily: fontSemiBold, marginTop: 12 }]}>Endereço</Text>
        <View style={styles.cepRow}>
          <View style={styles.cepInput}>
            <InputField label="CEP" value={cep} onChangeText={setCep} onBlur={handleCepBlur} placeholder="99999-999" keyboardType="number-pad" error={errors.cep} />
          </View>
          {cepLoading && <ActivityIndicator style={styles.cepSpinner} color={Colors.gold} size="small" />}
        </View>

        {cepManual && (
          <>
            <InputField label="Rua" value={street} onChangeText={setStreet} placeholder="Rua Blabla" autoCapitalize="words" error={errors.street} />
            <InputField label="Bairro" value={neighborhood} onChangeText={setNeighborhood} placeholder="Centro" autoCapitalize="words" error={errors.neighborhood} />
            <View style={styles.row}>
              <View style={{ flex: 2 }}>
                <InputField label="Cidade" value={city} onChangeText={setCity} placeholder="São Paulo" autoCapitalize="words" error={errors.city} />
              </View>
              <View style={{ flex: 1 }}>
                <InputField label="UF" value={state} onChangeText={setState} placeholder="SP" autoCapitalize="characters" error={errors.state} />
              </View>
            </View>
          </>
        )}

        {!cepManual && (
          <>
            {!!street && <InputField label="Rua" value={street} onChangeText={setStreet} editable={false} error={errors.street} />}
            {!!neighborhood && <InputField label="Bairro" value={neighborhood} onChangeText={setNeighborhood} editable={false} error={errors.neighborhood} />}
            {!!city && <InputField label="Cidade" value={city} onChangeText={setCity} editable={false} error={errors.city} />}
          </>
        )}

        <InputField label="Número" value={number} onChangeText={setNumber} placeholder="999" keyboardType="number-pad" error={errors.number} />
        <InputField label="Complemento" value={complement} onChangeText={setComplement} placeholder="Loja 99" error={errors.complement} />

        {globalError ? <Text style={styles.errorText}>{globalError}</Text> : null}
        
        <View style={styles.loginRow}>
          <Text style={[styles.loginText, { fontFamily: fontRegular }]}>Já tem uma conta? </Text>
          <Link href="/login" style={[styles.loginLink, { fontFamily: fontSemiBold }]}>Entrar</Link>
        </View>
      </ScrollView>

      <View style={[styles.footer, { paddingBottom: insets.bottom + 16 }]}>
        <Button label={isSubmitting ? "Criando conta..." : "Criar conta e Empresa"} onPress={handleRegister} disabled={isSubmitting || cepLoading} />
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Colors.white },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: 16, paddingBottom: 12 },
  backBtn: { width: 36, height: 36, alignItems: 'center', justifyContent: 'center' },
  headerTitle: { color: Colors.dark, fontSize: 18, fontWeight: '600' },
  form: { paddingHorizontal: 20, paddingTop: 10, gap: 16 },
  sectionTitle: { color: Colors.dark, fontSize: 16, marginTop: 8 },
  cepRow: { flexDirection: 'row', alignItems: 'flex-end', gap: 8 },
  cepInput: { flex: 1 },
  cepSpinner: { marginBottom: 12 },
  row: { flexDirection: 'row', gap: 12 },
  footer: { paddingHorizontal: 20, paddingTop: 12, backgroundColor: Colors.white, borderTopWidth: 1, borderTopColor: Colors.grey100, position: 'absolute', bottom: 0, left: 0, right: 0 },
  errorText: { color: Colors.error, fontSize: 14, textAlign: 'center', marginTop: 8,fontWeight:'bold' },
  loginRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', marginTop: 8, paddingBottom: 20 },
  loginText: { color: Colors.grey400, fontSize: 14, lineHeight: 21.7, letterSpacing: -0.28 },
  loginLink: { color: Colors.gold, fontSize: 14, lineHeight: 21.7, letterSpacing: -0.28, fontWeight: '600' },
});
