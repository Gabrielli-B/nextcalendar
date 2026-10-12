/** Stub mínimo de react-native para rodar os services em Node (vitest). */
export const Platform = {
  OS: 'native' as const,
  select<T>(spec: { native?: T; web?: T; default?: T }): T | undefined {
    return spec.native ?? spec.default;
  },
};
