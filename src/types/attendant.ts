// Tipos do Módulo Atendente UNIQ
// Sprint 09 - Módulo de Atendimento via WhatsApp

export interface AttendantConfig {
  id: string;
  id_empresa: string;
  agent_name: string;
  agent_personality?: string;
  mode: 'ura' | 'agent';
  avatar_url?: string;
  welcome_message?: string;
  away_message?: string;
  business_hours: BusinessHours;
  phone_number?: string;
  evolution_instance_id?: string;
  ura_rules: UraRule[];
  n8n_workflow_id?: string;
  status: 'active' | 'inactive' | 'paused';
  created_at: string;
  updated_at: string;
}

export interface BusinessHours {
  mon?: { open: string; close: string } | null;
  tue?: { open: string; close: string } | null;
  wed?: { open: string; close: string } | null;
  thu?: { open: string; close: string } | null;
  fri?: { open: string; close: string } | null;
  sat?: { open: string; close: string } | null;
  sun?: { open: string; close: string } | null;
}

export interface UraRule {
  id: string;
  keyword: string;
  response: string;
  active: boolean;
}

export interface Conversation {
  id: string;
  id_empresa: string;
  id_cliente?: string;
  remote_phone: string;
  remote_name?: string;
  status: 'open' | 'pending' | 'resolved' | 'archived';
  assigned_to?: string;
  last_message_at?: string;
  last_message_preview?: string;
  unread_count: number;
  created_at: string;
  updated_at: string;
  cliente?: {
    id: string;
    nome_cliente: string;
  };
}

export interface Message {
  id: string;
  id_conversa: string;
  direction: 'in' | 'out';
  sender_type: 'client' | 'agent' | 'system' | 'bot';
  sender_id?: string;
  content: string;
  media_url?: string;
  media_type?: string;
  message_type: 'text' | 'image' | 'audio' | 'document' | 'location' | 'video';
  external_id?: string;
  read_at?: string;
  is_automated: boolean;
  created_at: string;
  sender?: {
    id: string;
    nome: string;
  };
}

export interface QuickReply {
  id: string;
  id_empresa: string;
  shortcut: string;
  content: string;
  category?: string;
  created_at: string;
  updated_at: string;
}

export interface WebhookMessage {
  instance_id: string;
  message: {
    id: string;
    from: string;
    text: string;
    timestamp: string;
    type: 'text' | 'image' | 'audio' | 'document' | 'video';
    media_url?: string;
  };
}

export interface SendMessageRequest {
  conversation_id: string;
  content: string;
  sender_id: string;
  message_type?: 'text' | 'image' | 'audio';
}

export type ConversationFilter = 'all' | 'unread' | 'archived' | 'pending';

export interface ConversationFilters {
  status?: Conversation['status'];
  search?: string;
  assignedTo?: string;
}

// Tipos para o formulário de configuração
export interface AttendantConfigFormData {
  agent_name: string;
  agent_personality?: string;
  mode: 'ura' | 'agent';
  avatar_url?: string;
  welcome_message: string;
  away_message: string;
  business_hours: BusinessHours;
  phone_number?: string;
  evolution_instance_id?: string;
}

// Tipos para notificações
export interface NotificationSettings {
  sound: boolean;
  browser: boolean;
  badge: boolean;
  unread_alert_minutes: number;
}
