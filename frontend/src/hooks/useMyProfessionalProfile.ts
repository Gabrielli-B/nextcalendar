import { useCallback, useEffect, useState } from 'react';
import { useAuth } from '@/context/AuthContext';
import { getProfessionalMe, type ProfessionalMe } from '@/services/professionalServices';

export function useMyProfessionalProfile() {
  const { user } = useAuth();
  const [professional, setProfessional] = useState<ProfessionalMe | null>(null);
  const [error, setError] = useState<string | null>(null);
  /** `user.id` da última tentativa concluída (sucesso ou falha). */
  const [loadedFor, setLoadedFor] = useState<string | null>(null);
  const [reloadToken, setReloadToken] = useState(0);

  const isProfessional = !!user && user.role === 'PROFESSIONAL';

  /**
   * `loading` derivado dos dados: enquanto o perfil do profissional logado não
   * for carregado, está carregando. Nenhum `setState` síncrono no efeito
   * (`react-hooks/set-state-in-effect`).
   */
  const loading = isProfessional && loadedFor !== user!.id;

  useEffect(() => {
    if (!user || user.role !== 'PROFESSIONAL') return;

    const userId = user.id;
    let active = true;

    getProfessionalMe()
      .then((data) => {
        if (!active) return;
        setProfessional(data);
        setError(null);
      })
      .catch((err: any) => {
        if (!active) return;
        setError(err?.response?.data?.message || err?.message || 'Erro ao carregar dados do profissional.');
      })
      .finally(() => {
        if (!active) return;
        setLoadedFor(userId);
      });

    return () => {
      active = false;
    };
  }, [user, reloadToken]);

  /** Recarga manual, disparada por event handlers. */
  const load = useCallback(() => {
    setError(null);
    setLoadedFor(null);
    setReloadToken((token) => token + 1);
  }, []);

  return {
    professional,
    professionalId: professional?.id || null,
    establishmentId: professional?.establishmentId || null,
    loading,
    error,
    reload: load,
  };
}
