import { useSyncExternalStore } from 'react';
import { useColorScheme as useRNColorScheme } from 'react-native';

const emptySubscribe = () => () => {};

/**
 * To support static rendering, this value needs to be re-calculated on the client side for web
 *
 * `useSyncExternalStore` expõe um valor diferente no servidor (`false`) e no
 * cliente (`true`) sem efeito de montagem — o estado de hidratação é resolvido
 * pelo próprio React, evitando `setState` dentro de `useEffect`
 * (`react-hooks/set-state-in-effect`).
 */
export function useColorScheme() {
  const hasHydrated = useSyncExternalStore(
    emptySubscribe,
    () => true,
    () => false
  );

  const colorScheme = useRNColorScheme();

  if (hasHydrated) {
    return colorScheme;
  }

  return 'light';
}
