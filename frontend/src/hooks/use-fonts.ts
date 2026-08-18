import {
  WorkSans_400Regular,
  WorkSans_500Medium,
  WorkSans_600SemiBold,
  WorkSans_700Bold,
  useFonts,
} from '@expo-google-fonts/work-sans';

/**
 * Hook que carrega as fontes WorkSans do app.
 * Use em qualquer tela para obter os nomes das fontes.
 *
 * @example
 * const { fontRegular, fontSemiBold, loaded } = useAppFonts();
 */
export function useAppFonts() {
  const [loaded] = useFonts({
    'WorkSans-Regular': WorkSans_400Regular,
    'WorkSans-Medium': WorkSans_500Medium,
    'WorkSans-SemiBold': WorkSans_600SemiBold,
    'WorkSans-Bold': WorkSans_700Bold,
  });

  return {
    loaded,
    fontRegular: loaded ? 'WorkSans-Regular' : 'System',
    fontMedium: loaded ? 'WorkSans-Medium' : 'System',
    fontSemiBold: loaded ? 'WorkSans-SemiBold' : 'System',
    fontBold: loaded ? 'WorkSans-Bold' : 'System',
  };
}
