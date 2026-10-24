package com.nextcalendar.validation;

/**
 * Validação de CNPJ: 14 dígitos numéricos com dígitos verificadores módulo 11 (mesmo
 * algoritmo usado pelo gerador de CNPJ/CPF da suíte E2E em backend/e2e/run.sh).
 */
public final class CnpjValidator {

	private CnpjValidator() {
	}

	/**
	 * @param cnpj CNPJ com ou sem pontuação
	 * @return {@code true} se tiver 14 dígitos e os dígitos verificadores conferirem
	 */
	public static boolean isValid(String cnpj) {
		if (cnpj == null) {
			return false;
		}
		String digits = cnpj.replaceAll("\\D", "");
		if (digits.length() != 14) {
			return false;
		}
		String base = digits.substring(0, 12);
		String firstDigit = String.valueOf(checkDigit(base, true));
		String secondDigit = String.valueOf(checkDigit(base + firstDigit, false));
		return digits.equals(base + firstDigit + secondDigit);
	}

	private static int checkDigit(String base, boolean firstDigit) {
		int sum = 0;
		int weight = firstDigit ? 5 : 6;
		for (int i = 0; i < base.length(); i++) {
			sum += (base.charAt(i) - '0') * weight;
			weight = (weight == 2) ? 9 : weight - 1;
		}
		int remainder = sum % 11;
		return (remainder < 2) ? 0 : 11 - remainder;
	}

}
