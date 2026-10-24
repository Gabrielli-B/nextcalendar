import { useCallback, useEffect, useState } from 'react';
import { useAuth } from '@/context/AuthContext';
import { getEstablishmentByOwner } from '@/services/establishmentServices';

/**
 * Resolve o estabelecimento do gestor logado.
 * Usado por todas as telas da área do gestor (abas) para saber
 * qual establishmentId usar nas chamadas de API.
 */
export function useEstablishment() {
  const { user } = useAuth();

  const [establishment, setEstablishment] = useState<{ id: string; name: string } | null>(null);
  /** `user.id` da última tentativa concluída (sucesso ou falha). */
  const [loadedFor, setLoadedFor] = useState<string | null>(null);
  const [reloadToken, setReloadToken] = useState(0);

  /**
   * `loading` é derivado do estado de dados: enquanto o usuário logado ainda
   * não teve sua tentativa concluída, está carregando. Assim nenhum `setState`
   * acontece de forma síncrona no efeito (`react-hooks/set-state-in-effect`).
   */
  const loading = !!user?.id && loadedFor !== user.id;

  useEffect(() => {
    if (!user?.id) return;

    const userId = user.id;
    let active = true;

    getEstablishmentByOwner(userId)
      .then((est) => {
        if (!active) return;
        setEstablishment({ id: est.id, name: est.name || 'Minha Barbearia' });
      })
      .catch((error) => {
        if (!active) return;
        console.error('[ESTABLISHMENT] Erro ao carregar estabelecimento:', error);
        setEstablishment(null);
      })
      .finally(() => {
        if (!active) return;
        setLoadedFor(userId);
      });

    return () => {
      active = false;
    };
  }, [user?.id, reloadToken]);

  /** Recarga manual, disparada por event handlers (ex.: pull-to-refresh). */
  const reload = useCallback(() => {
    setLoadedFor(null);
    setReloadToken((token) => token + 1);
  }, []);

  return {
    establishmentId: user?.id ? establishment?.id ?? '' : '',
    establishmentName: user?.id ? establishment?.name ?? 'Minha Barbearia' : 'Minha Barbearia',
    loading,
    reload,
  };
}
