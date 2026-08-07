export type CanalType = 'whatsapp' | 'email' | 'chat' | 'instagram' | 'facebook' | 'telegram';

export interface CanalConfig {
  id: CanalType;
  nome: string;
  icone: string;
  cor: string;
  gradient?: string;
  ativo: boolean;
}

export const CANAIS_CONFIG: Record<CanalType, CanalConfig> = {
  whatsapp: {
    id: 'whatsapp',
    nome: 'WhatsApp',
    icone: 'MessageCircle',
    cor: '#25D366',
    ativo: true
  },
  email: {
    id: 'email',
    nome: 'E-mail',
    icone: 'Mail',
    cor: '#4285F4',
    ativo: true
  },
  chat: {
    id: 'chat',
    nome: 'Chat',
    icone: 'MessageSquare',
    cor: '#7C3AED',
    ativo: true
  },
  instagram: {
    id: 'instagram',
    nome: 'Instagram',
    icone: 'Instagram',
    cor: '#E4405F',
    gradient: 'linear-gradient(45deg, #f09433 0%, #e6683c 25%, #dc2743 50%, #cc2366 75%, #bc1888 100%)',
    ativo: true
  },
  facebook: {
    id: 'facebook',
    nome: 'Facebook',
    icone: 'Facebook',
    cor: '#1877F2',
    ativo: false
  },
  telegram: {
    id: 'telegram',
    nome: 'Telegram',
    icone: 'Send',
    cor: '#0088cc',
    ativo: false
  }
};

export interface UraOption {
  id: string;
  label: string;
  acao: 'transferir' | 'mensagem' | 'url';
  destino: string;
}

export interface UraConfig {
  boas_vindas: string;
  opcoes: UraOption[];
  tempo_espera: number;
}

export interface QuickReply {
  id: string;
  empresa_id: string;
  titulo: string;
  conteudo: string;
  atalho?: string;
  categoria: string;
  cor_tag: string;
  ordem: number;
  ativo: boolean;
  created_at: string;
  updated_at: string;
  created_by?: string;
}

export interface QuickReplyCategory {
  id: string;
  nome: string;
  cor: string;
  count: number;
}

export interface CRMChatConfig {
  id: string;
  empresa_id: string;
  agente_nome: string;
  agente_avatar_url: string | null;
  mensagem_boas_vindas: string;
  mensagem_ausencia: string;
  horario_funcionamento: {
    dias: Array<'seg' | 'ter' | 'qua' | 'qui' | 'sex' | 'sab' | 'dom'>;
    inicio: string;
    fim: string;
  };
  tempo_resposta_minutos: number;
  agente_ativo: boolean;
  ura_ativa: boolean;
  ura_config: UraConfig;
  created_at: string;
  updated_at: string;
}

export interface CRMChatConversa {
  id: string;
  empresa_id: string;
  contato_id: string;
  usuario_id?: string;
  status: 'pendente' | 'em_andamento' | 'resolvido' | 'arquivado';
  canal: CanalType;
  canal_id?: string;
  canal_dados?: {
    pushName?: string;
    profilePicture?: string;
    [key: string]: unknown;
  };
  ultima_mensagem?: string;
  unread_count: number;
  created_at: string;
  updated_at: string;
  contato?: {
    id: string;
    nome: string;
    telefone?: string;
    email?: string;
    avatar_url?: string;
  };
  usuario?: {
    id: string;
    nome: string;
    avatar_url?: string;
  };
  tags?: Array<{
    id: string;
    nome: string;
    cor: string;
  }>;
}

export interface CRMChatMensagem {
  id: string;
  conversa_id: string;
  remetente: 'contato' | 'usuario' | 'sistema' | 'agente';
  usuario_id?: string;
  tipo: 'texto' | 'imagem' | 'video' | 'audio' | 'documento' | 'localizacao';
  conteudo: string;
  arquivo_url?: string;
  status: 'recebida' | 'enviando' | 'enviada' | 'entregue' | 'lida' | 'falha';
  canal_mensagem_id?: string;
  metadata?: {
    caption?: string;
    mimeType?: string;
    fileName?: string;
    fileSize?: number;
  };
  created_at: string;
  updated_at: string;
}

export interface FiltroCanais {
  canais: CanalType[];
  busca: string;
  status: 'todos' | 'pendente' | 'em_andamento' | 'resolvido';
}
