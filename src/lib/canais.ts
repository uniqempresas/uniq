import { type CanalType, type CanalConfig, CANAIS_CONFIG } from '../types/crm-chat';

/**
 * Retorna a configuração completa de um canal
 * @param canal - Tipo do canal
 * @returns Configuração do canal
 * @example
 * const config = getCanalConfig('whatsapp');
 * console.log(config.cor); // '#25D366'
 */
export function getCanalConfig(canal: CanalType): CanalConfig {
  return CANAIS_CONFIG[canal];
}

/**
 * Retorna a cor de um canal
 * @param canal - Tipo do canal
 * @returns Código hexadecimal da cor
 * @example
 * const cor = getCanalColor('whatsapp');
 * console.log(cor); // '#25D366'
 */
export function getCanalColor(canal: CanalType): string {
  return CANAIS_CONFIG[canal]?.cor || '#6B7280';
}

/**
 * Retorna o nome do ícone Lucide para um canal
 * @param canal - Tipo do canal
 * @returns Nome do ícone
 * @example
 * const icone = getCanalIcon('whatsapp');
 * console.log(icone); // 'MessageCircle'
 */
export function getCanalIcon(canal: CanalType): string {
  return CANAIS_CONFIG[canal]?.icone || 'MessageSquare';
}

/**
 * Lista de canais ativos/habilitados
 */
export const CANAIS_ATIVOS: CanalType[] = Object.values(CANAIS_CONFIG)
  .filter(config => config.ativo)
  .map(config => config.id);

/**
 * Verifica se um canal está ativo
 * @param canal - Tipo do canal
 * @returns true se o canal está ativo
 */
export function isCanalAtivo(canal: CanalType): boolean {
  return CANAIS_CONFIG[canal]?.ativo ?? false;
}

/**
 * Retorna o nome de exibição de um canal
 * @param canal - Tipo do canal
 * @returns Nome legível do canal
 */
export function getCanalNome(canal: CanalType): string {
  return CANAIS_CONFIG[canal]?.nome || canal;
}

/**
 * Retorna o gradiente CSS de um canal (se existir)
 * @param canal - Tipo do canal
 * @returns String CSS do gradiente ou undefined
 */
export function getCanalGradient(canal: CanalType): string | undefined {
  return CANAIS_CONFIG[canal]?.gradient;
}
