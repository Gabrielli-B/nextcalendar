import { useState, useEffect, useCallback } from 'react'
import { getActiveProfessionals, getProfessionals, ProfessionalMin } from '../services/professionalServices'

export function useProfessional(establishmentId: string) {

    const [professionals, setProfessionals] = useState<ProfessionalMin[]>([])
    const [error, setError] = useState<string | null>(null)
    const [mode, setMode] = useState<'active' | 'all'>('active')
    /**
     * Chave da última requisição concluída (sucesso ou falha).
     * `loading` é derivado dela: enquanto a chave atual não for carregada,
     * a lista está carregando — sem `setState` síncrono no efeito.
     */
    const [loadedKey, setLoadedKey] = useState<string | null>(null)
    const [reloadToken, setReloadToken] = useState(0)

    const requestKey = establishmentId ? `${establishmentId}:${mode}` : null
    const loading = requestKey !== null && loadedKey !== requestKey

    /**
     * `setState` apenas em callbacks de promise (`.then/.catch/.finally`),
     * nunca no corpo síncrono do efeito — regra
     * `react-hooks/set-state-in-effect`.
     * `active` evita aplicar resultado de uma requisição já cancelada.
     */
    useEffect(() => {
        if (!establishmentId) return

        const key = `${establishmentId}:${mode}`
        let active = true
        const request = mode === 'active'
            ? getActiveProfessionals(establishmentId)
            : getProfessionals(establishmentId)

        request
            .then((response) => {
                if (!active) return
                setProfessionals(response.content)
                setError(null)
            })
            .catch(() => {
                if (!active) return
                setError('Erro ao carregar profissional')
            })
            .finally(() => {
                if (!active) return
                setLoadedKey(key)
            })

        return () => {
            active = false
        }
    }, [establishmentId, mode, reloadToken])

    /** Recarga manual, disparada por event handlers (ex.: pull-to-refresh). */
    const refetch = useCallback(() => {
        setLoadedKey(null)
        setReloadToken((token) => token + 1)
    }, [])

    return {
        professionals, loading, error, mode, setMode, refetch
    }
}
