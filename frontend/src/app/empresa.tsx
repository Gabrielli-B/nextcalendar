/**
 * Tela de perfil do Estabelecimento — aba "Empresa"
 *
 * UC01/UC03: Carrega dados do establishment do proprietário logado
 * UC02: Consulta CEP ao sair do campo e preenche endereço automaticamente
 * UC06: Salva as alterações via PUT /establishments/{id}
 */

import { useEffect, useRef, useState } from 'react';
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
import { useAuth } from '@/context/AuthContext';
import { useRouter } from 'expo-router';
import {
  consultarCep,
  getEstablishmentByOwner,
  updateEstablishment,
  type EstablishmentResponse,
} from '@/services/establishmentServices';

// ─── Abas do perfil ───────────────────────────────────────────────────────

const TABS = ['Perfil', 'Empresa', 'Links', 'Senha'] as const;
type Tab = typeof TABS[number];

// ─── Componente principal ─────────────────────────────────────────────────

export default function EmpresaScreen() {
  const { fontRegular, fontSemiBold } = useAppFonts();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { user } = useAuth();

  const [activeTab, setActiveTab] = useState<Tab>('Empresa');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [cepLoading, setCepLoading] = useState(false);
  const [cepManual, setCepManual] = useState(false); // UC02 6b: modo manual

  // Dados do establishment
  const [establishmentId, setEstablishmentId] = useState<string | null>(null);

  // Campos do formulário — tela Empresa
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [whatsapp, setWhatsapp] = useState('');
  const [cnpj, setCnpj] = useState('');

  // Endereço
  const [cep, setCep] = useState('');
  const [street, setStreet] = useState('');
  const [number, setNumber] = useState('');
  const [complement, setComplement] = useState('');
  const [city, setCity] = useState('');
  const [neighborhood, setNeighborhood] = useState('');
  const [state, setState] = useState('');

  // ─── UC03: Carregar dados ao montar ──────────────────────────────────

  useEffect(() => {
    if (!user?.id) return;

    async function loadEstablishment() {
      try {
        setLoading(true);
        const data: EstablishmentResponse = await getEstablishmentByOwner(user!.id);
        populateForm(data);
      } catch (err: any) {
        if (err?.response?.status === 404) {
          // Establishment ainda não cadastrado — formulário vazio para criação
        } else {
          Alert.alert('Erro', 'Não foi possível carregar os dados da empresa.');
        }
      } finally {
        setLoading(false);
      }
    }

    loadEstablishment();
  }, [user?.id]);

  function populateForm(data: EstablishmentResponse) {
    setEstablishmentId(data.id);
    setName(data.name ?? '');
    setEmail(data.email ?? '');
    setPhone(data.phone ?? '');
    setWhatsapp(data.whatsapp ?? '');
    setCnpj(data.cnpj ?? '');
    setCep(data.address?.cep ?? '');
    setStreet(data.address?.street ?? '');
    setNumber(data.address?.number ?? '');
    setComplement(data.address?.complement ?? '');
    setCity(data.address?.city ?? '');
    setNeighborhood(data.address?.neighborhood ?? '');
    setState(data.address?.state ?? '');
  }

  // ─── UC02: Consultar CEP ao sair do campo ─────────────────────────────

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
        // UC02 1a: CEP não encontrado
        Alert.alert('CEP não encontrado', 'Verifique o CEP ou preencha o endereço manualmente.');
        setCepManual(true);
      } else {
        // UC02 1b: API indisponível → modo manual
        Alert.alert(
          'Serviço de CEP indisponível',
          'Preencha o endereço manualmente.'
        );
        setCepManual(true);
      }
    } finally {
      setCepLoading(false);
    }
  }

  // ─── UC06: Salvar alterações ──────────────────────────────────────────

  async function handleSave() {
    if (!establishmentId) {
      Alert.alert('Atenção', 'Nenhum estabelecimento encontrado para salvar.');
      return;
    }

    try {
      setSaving(true);
      await updateEstablishment(establishmentId, {
        name,
        email,
        phone,
        whatsapp,
        address: {
          cep: cep.replace(/\D/g, ''),
          number,
          complement,
          ...(cepManual && { street, neighborhood, city, state }),
        },
      });
      Alert.alert('Salvo!', 'Dados da empresa atualizados com sucesso.');
    } catch (err: any) {
      const status = err?.response?.status;
      if (status === 422) {
        // UC06 3a: dados inválidos
        const msg = err?.response?.data?.[0]?.message ?? 'Verifique os dados informados.';
        Alert.alert('Dados inválidos', msg);
      } else {
        Alert.alert('Erro', 'Não foi possível salvar. Tente novamente.');
      }
    } finally {
      setSaving(false);
    }
  }

  // ─── Render ───────────────────────────────────────────────────────────

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color={Colors.gold} />
      </View>
    );
  }

  return (
    <KeyboardAvoidingView
      style={styles.root}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>

      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + 12 }]}>
        <TouchableOpacity style={styles.backBtn} onPress={() => router.back()}>
          <ChevronLeftIcon size={20} color={Colors.dark} />
        </TouchableOpacity>
        <Text style={[styles.headerTitle, { fontFamily: fontSemiBold }]}>Empresa</Text>
        <View style={styles.backBtn} />
      </View>

      {/* Tabs: Perfil | Empresa | Links | Senha */}
      <View style={styles.tabsRow}>
        {TABS.map((tab) => (
          <TouchableOpacity
            key={tab}
            style={[styles.tab, activeTab === tab && styles.tabActive]}
            onPress={() => setActiveTab(tab)}>
            <Text style={[
              styles.tabText,
              { fontFamily: fontSemiBold },
              activeTab === tab && styles.tabTextActive,
            ]}>
              {tab}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Formulário — apenas aba Empresa implementada */}
      {activeTab === 'Empresa' && (
        <ScrollView
          contentContainerStyle={[
            styles.form,
            { paddingBottom: insets.bottom + 100 },
          ]}
          showsVerticalScrollIndicator={false}
          keyboardShouldPersistTaps="handled">

          <InputField
            label="Nome da Empresa"
            value={name}
            onChangeText={setName}
            placeholder="Studio Vision"
            autoCapitalize="words"
          />

          <InputField
            label="Email"
            value={email}
            onChangeText={setEmail}
            placeholder="joao.silva@gmail.com"
            keyboardType="email-address"
          />

          <InputField
            label="Celular"
            value={phone}
            onChangeText={setPhone}
            placeholder="(99) 99999-9999"
            keyboardType="phone-pad"
          />

          <InputField
            label="Whatsapp"
            value={whatsapp}
            onChangeText={setWhatsapp}
            placeholder="(99) 99999-9999"
            keyboardType="phone-pad"
          />

          {/* CNPJ — somente leitura após cadastro */}
          <InputField
            label="CPF/CNPJ"
            value={cnpj}
            onChangeText={() => {}}
            placeholder="00000000000000"
            editable={false}
          />

          {/* ─── Endereço ── */}
          <View style={styles.cepRow}>
            <View style={styles.cepInput}>
              <InputField
                label="CEP"
                value={cep}
                onChangeText={setCep}
                onBlur={handleCepBlur}
                placeholder="99999-999"
                keyboardType="number-pad"
              />
            </View>
            {cepLoading && (
              <ActivityIndicator
                style={styles.cepSpinner}
                color={Colors.gold}
                size="small"
              />
            )}
          </View>

          {/* UC02 1b: campos manuais aparecem quando API indisponível */}
          {cepManual && (
            <>
              <InputField
                label="Rua"
                value={street}
                onChangeText={setStreet}
                placeholder="Rua Blabla"
                autoCapitalize="words"
              />
              <InputField
                label="Bairro"
                value={neighborhood}
                onChangeText={setNeighborhood}
                placeholder="Centro"
                autoCapitalize="words"
              />
              <View style={styles.row}>
                <View style={{ flex: 2 }}>
                  <InputField
                    label="Cidade"
                    value={city}
                    onChangeText={setCity}
                    placeholder="São Paulo"
                    autoCapitalize="words"
                  />
                </View>
                <View style={{ flex: 1 }}>
                  <InputField
                    label="UF"
                    value={state}
                    onChangeText={setState}
                    placeholder="SP"
                    autoCapitalize="characters"
                  />
                </View>
              </View>
            </>
          )}

          {/* Campos de endereço preenchidos automaticamente (só leitura) */}
          {!cepManual && (
            <>
              {!!street && (
                <InputField
                  label="Rua"
                  value={street}
                  onChangeText={setStreet}
                  editable={false}
                />
              )}
              {!!city && (
                <InputField
                  label="Cidade"
                  value={city}
                  onChangeText={setCity}
                  editable={false}
                />
              )}
            </>
          )}

          <InputField
            label="Número"
            value={number}
            onChangeText={setNumber}
            placeholder="999"
            keyboardType="number-pad"
          />

          <InputField
            label="Complemento"
            value={complement}
            onChangeText={setComplement}
            placeholder="Loja 99"
          />

        </ScrollView>
      )}

      {activeTab !== 'Empresa' && (
        <View style={styles.center}>
          <Text style={[styles.placeholder, { fontFamily: fontRegular }]}>
            Em breve...
          </Text>
        </View>
      )}

      {/* Botão Salvar fixo no rodapé */}
      {activeTab === 'Empresa' && (
        <View style={[styles.footer, { paddingBottom: insets.bottom + 16 }]}>
          <Button
            label={saving ? 'Salvando...' : 'Salvar'}
            onPress={handleSave}
            disabled={saving}
          />
        </View>
      )}
    </KeyboardAvoidingView>
  );
}

// ─── Estilos ──────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: Colors.white,
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  placeholder: {
    color: Colors.grey400,
    fontSize: 15,
  },

  // Header
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingBottom: 12,
  },
  backBtn: {
    width: 36,
    height: 36,
    alignItems: 'center',
    justifyContent: 'center',
  },
  headerTitle: {
    color: Colors.dark,
    fontSize: 18,
    fontWeight: '600',
  },

  // Tabs
  tabsRow: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    borderBottomColor: Colors.grey100,
    gap: 4,
  },
  tab: {
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 20,
    marginBottom: 8,
  },
  tabActive: {
    backgroundColor: Colors.gold,
  },
  tabText: {
    color: Colors.grey500,
    fontSize: 13,
  },
  tabTextActive: {
    color: Colors.white,
  },

  // Formulário
  form: {
    paddingHorizontal: 20,
    paddingTop: 20,
    gap: 16,
  },

  // CEP com spinner
  cepRow: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    gap: 8,
  },
  cepInput: {
    flex: 1,
  },
  cepSpinner: {
    marginBottom: 12,
  },

  // Linha para cidade + UF
  row: {
    flexDirection: 'row',
    gap: 12,
  },

  // Footer
  footer: {
    paddingHorizontal: 20,
    paddingTop: 12,
    backgroundColor: Colors.white,
    borderTopWidth: 1,
    borderTopColor: Colors.grey100,
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
  },
});
