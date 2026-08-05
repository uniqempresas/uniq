# 🗄️ Mapeamento do Banco de Dados — Protótipo Supabase (Base UNIQ)

> **Data da análise:** 05/08/2026
> **Fonte:** Output do `list_tables` (schemas `public` e `auth`) + Edge Functions
> **Objetivo:** Documentar o schema existente no protótipo para orientar o desenvolvimento do MVP.
> **Restrição:** Nenhuma tabela foi criada ou alterada nesta fase.

---

## 1. Resumo Geral

| Métrica | Valor |
|---|---|
| **Total de tabelas** | **91** |
| Schema `auth.*` | 22 tabelas (nativas do Supabase Auth) |
| Schema `public.*` | 69 tabelas (domínio da aplicação) |
| Tabelas com RLS ativo | ~17 (auth.* em maioria + crm_chat_*, est_*, me_venda*, cx_contas, cx_movimentacao_caixa, fn_*, unq_*, mel_chat_custos, me_empresa_endereco) |
| Tabelas **sem RLS** | **52** (⚠️ vulnerabilidade crítica — ver seção 11) |
| Tabelas com dados reais | `mel_chat` (27 linhas), `crm_chat_conversas` (15), `crm_chat_mensagens` (41) |
| Tabelas de teste a ignorar | `public.teste_opencode`, `public.teste_03` |
| **Edge Functions ativas** | 4 |

---

## 2. Edge Functions

| Function | Status | JWT | Observação |
|---|---|---|---|
| `create-user` | ACTIVE | ✅ Sim | Cria usuário no `auth.users` e perfil em `me_usuario` |
| `crm-webhook-proxy` | ACTIVE | ✅ Sim | Recebe webhooks do n8n/CRM *(código não legível — Unauthorized)* |
| `webhook-whatsapp` | ACTIVE | ❌ Não | Recebe eventos do WhatsApp via Evolution API *(código não legível — Unauthorized)* |
| `send-whatsapp-message` | ACTIVE | ❌ Não | Envia mensagens de volta para o WhatsApp *(código não legível — Unauthorized)* |

### `create-user` — código disponível

- **Entrada:** `{ email, password, nome, cargo_id, empresa_id }`
- **Ação:**
  1. Cria usuário no Supabase Auth com `email_confirm: true`.
  2. Insere registro em `me_usuario` vinculando `id` ao `auth.users.id`, `cargo` e `empresa_id`.
  3. Se falhar a inserção em `me_usuario`, faz rollback deletando o usuário do Auth.
- **Saída:** `{ user, message: 'User created successfully' }` ou `{ error }`
- **Uso provável:** criação de colaboradores/usuários dentro de uma empresa já existente.

### Functions não lidas

As funções `crm-webhook-proxy`, `webhook-whatsapp` e `send-whatsapp-message` retornaram `Unauthorized` na leitura. Isso pode indicar:
- Permissão da API key usada não permite ler código de Edge Functions (somente listar).
- Ou configuração específica de acesso restrito.

> **Ação futura:** obter o código dessas functions antes da integração (Fases 3 e 4).

---

## 3. Core / Tenant (Multi-empresa)

### `public.me_empresa` — Tabela central do multi-tenant

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | `uuid_generate_v4()` |
| `nome_fantasia` | `text?` | Nome da empresa |
| `cnpj` | `text?` | |
| `telefone` | `text?` | |
| `email` | `text?` | |
| `slug` | `text?` | Identificador URL |
| `logo_url` | `text?` | URL do logo |
| `store_config` | `jsonb?` | Configurações da loja virtual (JSON) |
| `appearance` | `jsonb?` | Configurações de aparência (JSON) |
| `created_at` | `timestamptz?` | `now()` |

**RLS:** ❌ Desabilitado  
**Observação:** Deleção em cascata remove TODOS os dados da empresa. Referenciada por ~40 tabelas via `empresa_id`.

---

### `public.me_usuario` — Usuários do sistema

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | FK → `auth.users.id` (mesmo UUID) |
| `empresa_id` | `uuid?` | FK → `me_empresa.id` |
| `email` | `text?` | |
| `cargo` | `integer?` | FK → `me_cargo.id` |
| `nome_usuario` | `text?` | |
| `role` | `text?` | `default 'colaborador'` |
| `ativo` | `boolean?` | `default true` |

**RLS:** ❌ Desabilitado  
**Relação com auth.users:** `me_usuario.id` = `auth.users.id`. O usuário é criado primeiro no auth, depois o registro é espelhado em `me_usuario` com a FK para a empresa.

---

### `public.me_cargo` — Cargos / funções

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | FK → `me_empresa.id` |
| `nome_cargo` | `text NOT NULL` | |
| `descricao` | `text?` | |
| `ativo` | `boolean?` | `default true` |

**RLS:** ❌ Desabilitado

---

### `public.me_empresa_endereco` — Endereços da empresa

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | FK → `me_empresa.id` |
| `cep`, `logradouro`, `numero`, `bairro`, `cidade`, `uf` | `text NOT NULL` | |
| `complemento`, `ibge` | `text?` | |

**RLS:** ✅ Ativo

---

### `public.unq_modulos_sistema` — Catálogo global de módulos

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `nome` | `text NOT NULL` | Nome do módulo |
| `descricao` | `text?` | |
| `codigo` | `text?` | Código identificador do módulo |
| `categoria` | `text?` | `'base'` (sempre ativo) ou `'opcional'` |
| `preco_mensal` | `numeric?` | `default 0.00` |
| `preco_anual` | `numeric?` | `default 0.00` |
| `icone` | `text?` | |
| `funcionalidades` | `jsonb?` | `default '[]'` |
| `status` | `text?` | `default 'active'` |

**RLS:** ✅ Ativo

---

### `public.unq_empresa_modulos` — Módulos contratados por empresa

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | FK → `me_empresa.id` |
| `modulo_id` | `uuid NOT NULL` | FK → `unq_modulos_sistema.id` |
| `status` | `text?` | `'active'` ou `'inactive'` |
| `data_contratacao` | `timestamptz?` | `default now()` |

**RLS:** ✅ Ativo

---

### `public.me_modulo_cargo` — Permissão de módulos por cargo

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | FK → `me_empresa.id` |
| `cargo_id` | `integer NOT NULL` | FK → `me_cargo.id` |
| `modulo_codigo` | `text NOT NULL` | Código do módulo |
| `ativo` | `boolean?` | `default true` |

**RLS:** ❌ Desabilitado

---

### `public.me_modulo_ativo` — Módulos ativos por empresa

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | FK → `me_empresa.id` |
| `modulo_codigo` | `text NOT NULL` | |
| `ativo` | `boolean?` | `default true` |

**RLS:** ❌ Desabilitado

---

## 4. CRM

### `public.crm_leads` — Leads (pré-clientes)

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `nome` | `text NOT NULL` | |
| `email` | `text?` | |
| `telefone` | `text?` | |
| `status` | `text?` | `default 'Novo'` |
| `origem` | `text?` | |
| `foto_url` | `text?` | |
| `empresa_nome` | `text?` | Nome da empresa do lead |
| `ltv` | `numeric?` | `default 0` |
| `ultima_interacao` | `timestamptz?` | |
| `observacoes` | `text?` | |

**RLS:** ❌ Desabilitado  
**FKs:** `crm_chat_conversas.lead_id`, `crm_oportunidades.lead_id`

---

### `public.crm_etapas` — Etapas do funil de vendas

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | FK → `me_empresa.id` |
| `nome` | `text?` | Ex: Novo Lead, Qualificado, Proposta |
| `posicao` | `integer?` | Ordem no funil |
| `cor` | `text?` | Cor da etapa |
| `fixa` | `boolean?` | `default false` |

**RLS:** ❌ Desabilitado

---

### `public.crm_oportunidades` — Oportunidades de negócio

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `cliente_id` | `uuid?` | FK → `me_cliente.id` |
| `lead_id` | `uuid?` | FK → `crm_leads.id` |
| `titulo` | `text NOT NULL` | |
| `valor` | `numeric?` | `default 0` |
| `estagio` | `text?` | `default 'Prospecção'` |
| `data_fechamento` | `date?` | |

**RLS:** ❌ Desabilitado

---

### `public.crm_oportunidade_produtos` — Produtos em oportunidades

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `oportunidade_id` | `uuid?` | FK → `crm_oportunidades.id` |
| `produto_id` | `bigint?` | FK → `me_produto.id` |
| `quantidade` | `integer NOT NULL` | `default 1` |
| `preco_unitario` | `numeric NOT NULL` | |

**RLS:** ❌ Desabilitado

---

### `public.crm_atendimentos` — Atendimentos a clientes

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `cliente_id` | `uuid?` | FK → `me_cliente.id` |
| `titulo` | `text NOT NULL` | |
| `descricao` | `text?` | |
| `status` | `text?` | `default 'Aberto'` |
| `prioridade` | `text?` | `default 'Média'` |

**RLS:** ❌ Desabilitado

---

### `public.crm_atividades` — Tarefas do CRM

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `oportunidade_id` | `uuid?` | FK → `crm_oportunidades.id` |
| `tipo` | `text NOT NULL` | Ex: ligação, email, reunião |
| `descricao` | `text NOT NULL` | |
| `data_vencimento` | `timestamptz?` | |
| `concluido` | `boolean?` | `default false` |
| `criado_por` | `uuid?` | FK → `auth.users.id` |

**RLS:** ❌ Desabilitado

---

### `public.crm_origem` — Origens de captura de leads

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `nome` | `text NOT NULL` | Ex: Site, Instagram, Indicação |

**RLS:** ❌ Desabilitado

---

### `public.crm_chat_conversas` — Conversas do chat CRM

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `text PK` | `gen_random_uuid()` (armazenado como text) |
| `empresa_id` | `uuid NOT NULL` | FK → `me_empresa.id` |
| `cliente_id` | `uuid?` | FK → `me_cliente.id` |
| `lead_id` | `uuid?` | FK → `crm_leads.id` |
| `status` | `text?` | `default 'aberto'` |
| `modo` | `text?` | `default 'bot'` |
| `canal` | `text?` | `whatsapp`, `email`, `chat`, `instagram`, `facebook`, `telegram` |
| `canal_id` | `varchar?` | ID externo (telefone, email, etc.) |
| `canal_dados` | `jsonb?` | Dados específicos do canal |
| `nome` | `text?` | Nome do contato |
| `foto_contato` | `text?` | |
| `titulo` | `text?` | |

**RLS:** ✅ Ativo (Bug #36)  
**Dados:** 15 registros

---

### `public.crm_chat_mensagens` — Mensagens do chat CRM

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `conversa_id` | `text NOT NULL` | FK → `crm_chat_conversas.id` |
| `remetente_tipo` | `text NOT NULL` | |
| `remetente_id` | `uuid?` | |
| `conteudo` | `text?` | |
| `tipo_conteudo` | `text?` | `default 'texto'` |
| `tipo` | `text?` | `texto`, `imagem`, `audio`, `documento`, `video` |
| `arquivo_url` | `text?` | |
| `canal_mensagem_id` | `text?` | ID da mensagem no canal externo (WhatsApp) |
| `status` | `text?` | `'recebida'`, `'enviada'`, `'entregue'`, `'lida'`, `'falha'` |
| `lido` | `boolean?` | `default false` |
| `metadados` | `jsonb?` | |

**RLS:** ✅ Ativo (Bug #36)  
**Dados:** 41 registros

---

### `public.crm_chat_config` — Configuração do chat por empresa

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | FK → `me_empresa.id` |
| `agente_nome` | `varchar NOT NULL` | `default 'Assistente Virtual'` |
| `agente_avatar_url` | `text?` | |
| `mensagem_boas_vindas` | `text NOT NULL` | |
| `mensagem_ausencia` | `text NOT NULL` | |
| `horario_funcionamento` | `jsonb NOT NULL` | `{dias, inicio, fim}` |
| `tempo_resposta_minutos` | `integer NOT NULL` | `default 5` |
| `agente_ativo` | `boolean NOT NULL` | `default true` |
| `ura_ativa` | `boolean NOT NULL` | `default false` |
| `ura_config` | `jsonb?` | Configuração da URA (opções, boas-vindas) |
| `evolution_instance_id` | `text?` | ID na Evolution API |
| `evolution_api_key` | `text?` | API Key Evolution |
| `evolution_base_url` | `text?` | `default 'https://api.evolution-api.com'` |
| `webhook_url` | `text?` | Webhook Evolution |

**RLS:** ✅ Ativo (Bug #36)  
**⚠️ Contém credenciais da Evolution API** — cuidado com exposição.

---

### `public.crm_chat_respostas_rapidas` — Respostas pré-cadastradas

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | FK → `me_empresa.id` |
| `titulo` | `varchar NOT NULL` | |
| `conteudo` | `text NOT NULL` | |
| `atalho` | `varchar?` | Ex: `/suporte` |
| `categoria` | `varchar?` | `default 'geral'` |
| `cor_tag` | `varchar?` | `default '#6B7280'` |
| `ordem` | `integer NOT NULL` | `default 0` |
| `ativo` | `boolean NOT NULL` | `default true` |
| `created_by` | `uuid?` | FK → `auth.users.id` |

**RLS:** ✅ Ativo

---

## 5. Melissa (IA / Consultoria)

### `public.mel_consultoria_config` — Configuração da consultoria Melissa

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | FK → `me_empresa.id` |
| `projeto_id` | `uuid?` | FK → `mel_projetos.id` |
| `pergunta` | `text?` | |

**RLS:** ❌ Desabilitado

---

### `public.mel_consultoria` — Sessões de consultoria

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `nome_cliente` | `text?` | |
| `n_telefone` | `text?` | |
| `empresa` | `text?` | |
| `email` | `text?` | |
| `etapa_funil` | `text NOT NULL` | `default 'inicial'` |
| `conclusao` | `boolean?` | `default false` |
| + 20 campos de diagnóstico | `text?` | Ramo, funcionários, dores, faturamento, etc. |

**RLS:** ❌ Desabilitado

---

### `public.mel_chat` — Mensagens do chat com a Melissa

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `integer PK` | `serial` |
| `session_id` | `varchar NOT NULL` | |
| `message` | `jsonb NOT NULL` | Conteúdo completo da mensagem |

**RLS:** ❌ Desabilitado  
**Dados:** 27 registros (tabela mais populada do sistema)

---

### `public.mel_chat_buffer` — Buffer de mensagens

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `n_telefone` | `text NOT NULL` | |
| `time_msg` | `integer NOT NULL` | |
| `mensagem` | `text?` | |
| `id_mensagem` | `text?` | |

**RLS:** ❌ Desabilitado

---

### `public.mel_chat_custos` — Custos de tokens/IA

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `date` | `date?` | |
| `model` | `text?` | Modelo de IA usado |
| `input_tokens` | `bigint?` | |
| `output_tokens` | `bigint?` | |
| `total_tokens` | `bigint?` | |
| `workflowId` | `text?` | ID do workflow n8n |
| `executionId` | `text?` | ID da execução n8n |

**RLS:** ✅ Ativo

---

### `public.mel_projetos` — Projetos de consultoria

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | FK → `me_empresa.id` |
| `nome_projeto` | `text NOT NULL` | |
| `descricao` | `text?` | |

**RLS:** ❌ Desabilitado

---

## 6. WhatsApp / Atendente (ATD — legado)

> **Contexto:** O módulo Atendente (ATD) está sendo migrado para o CRM. A tabela `_migracao_atd_log` registra essa migração.

### `public.atd_config` — Configuração do atendente virtual

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `id_empresa` | `uuid?` | FK → `me_empresa.id` |
| `agent_name` | `varchar NOT NULL` | `default 'Atendente UNIQ'` |
| `agent_personality` | `text?` | Personalidade do agente |
| `mode` | `varchar?` | `default 'ura'` |
| `avatar_url` | `text?` | |
| `welcome_message` | `text?` | |
| `away_message` | `text?` | |
| `business_hours` | `jsonb?` | Horários de funcionamento |
| `phone_number` | `varchar?` | Número de WhatsApp |
| `evolution_instance_id` | `varchar?` | Instância Evolution (legado) |
| `ura_rules` | `jsonb?` | `default '[]'` |
| `n8n_workflow_id` | `varchar?` | Workflow n8n associado |
| `status` | `varchar?` | `default 'active'` |

**RLS:** ❌ Desabilitado

---

### `public.atd_conversas` — Conversas de WhatsApp (legado)

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `id_empresa` | `uuid?` | FK → `me_empresa.id` |
| `id_cliente` | `uuid?` | FK → `me_cliente.id` |
| `remote_phone` | `varchar NOT NULL` | Telefone do contato |
| `remote_name` | `varchar?` | Nome do contato |
| `status` | `varchar?` | `default 'open'` |
| `assigned_to` | `uuid?` | FK → `me_usuario.id` |
| `last_message_at` | `timestamptz?` | |
| `last_message_preview` | `text?` | |
| `unread_count` | `integer?` | `default 0` |

**RLS:** ❌ Desabilitado

---

### `public.atd_mensagens` — Mensagens de WhatsApp (legado)

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `id_conversa` | `uuid?` | FK → `atd_conversas.id` |
| `direction` | `varchar?` | `inbound` / `outbound` |
| `sender_type` | `varchar?` | |
| `sender_id` | `uuid?` | FK → `me_usuario.id` |
| `content` | `text NOT NULL` | |
| `media_url` | `text?` | |
| `media_type` | `varchar?` | |
| `external_id` | `varchar?` | ID externo (WhatsApp) |
| `is_automated` | `boolean?` | `default false` |

**RLS:** ❌ Desabilitado

---

### `public.atd_respostas_rapidas` — Atalhos de respostas (legado)

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `id_empresa` | `uuid?` | FK → `me_empresa.id` |
| `shortcut` | `varchar NOT NULL` | Atalho (ex: `/ola`) |
| `content` | `text NOT NULL` | Texto da resposta |
| `category` | `varchar?` | |

**RLS:** ❌ Desabilitado

---

### `public._migracao_atd_log` — Log de migração ATD → CRM

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `tabela_origem` | `varchar NOT NULL` | |
| `tabela_destino` | `varchar NOT NULL` | |
| `registros_processados` | `integer?` | `default 0` |
| `registros_erro` | `integer?` | `default 0` |
| `started_at` | `timestamptz?` | |
| `completed_at` | `timestamptz?` | |
| `erro_detalhes` | `jsonb?` | `default '[]'` |

**RLS:** ❌ Desabilitado

---

## 7. Financeiro

### Contas e Movimentação Financeira (`me_*`)

#### `public.me_conta` — Contas financeiras

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | FK → `me_empresa.id` |
| `nome` | `varchar NOT NULL` | |
| `tipo` | `varchar NOT NULL` | Ex: `corrente`, `poupanca`, `caixa` |
| `banco_codigo`, `agencia`, `conta` | `varchar?` | Dados bancários |
| `saldo_inicial` | `numeric?` | `default 0` |
| `saldo_atual` | `numeric?` | `default 0` |
| `ativo` | `boolean?` | `default true` |

**RLS:** ❌ Desabilitado

---

#### `public.me_categoria_financeira` — Categorias de receitas/despesas

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `nome` | `varchar NOT NULL` | |
| `tipo` | `varchar NOT NULL` | `'receita'` ou `'despesa'` |
| `cor` | `varchar?` | `default '#64748b'` |
| `ativo` | `boolean?` | `default true` |

**RLS:** ❌ Desabilitado

---

#### `public.me_contas_receber` — Contas a receber

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `cliente_id` | `uuid?` | FK → `me_cliente.id` |
| `venda_id` | `uuid?` | FK → `me_venda.id` |
| `descricao` | `varchar?` | |
| `valor` | `numeric NOT NULL` | |
| `data_vencimento` | `date NOT NULL` | |
| `data_pagamento` | `date?` | |
| `valor_pago` | `numeric?` | |
| `status` | `varchar?` | `default 'pendente'` |
| `conta_id` | `uuid?` | FK → `me_conta.id` |
| `categoria_id` | `uuid?` | FK → `me_categoria_financeira.id` |

**RLS:** ❌ Desabilitado

---

#### `public.me_contas_pagar` — Contas a pagar

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `fornecedor_id` | `uuid?` | FK → `me_fornecedor.id` |
| `descricao` | `varchar NOT NULL` | |
| `valor` | `numeric NOT NULL` | |
| `data_vencimento` | `date NOT NULL` | |
| `data_pagamento` | `date?` | |
| `status` | `varchar?` | `default 'pendente'` |
| `conta_id` | `uuid?` | FK → `me_conta.id` |
| `categoria_id` | `uuid?` | FK → `me_categoria_financeira.id` |

**RLS:** ❌ Desabilitado

---

#### `public.me_movimentacao_financeira` — Movimentações financeiras (baixas)

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `conta_id` | `uuid NOT NULL` | FK → `me_conta.id` |
| `tipo` | `varchar NOT NULL` | `'entrada'` ou `'saida'` |
| `valor` | `numeric NOT NULL` | |
| `data_movimentacao` | `date NOT NULL` | |
| `categoria_id` | `uuid?` | FK → `me_categoria_financeira.id` |
| `conta_receber_id` | `uuid?` | FK → `me_contas_receber.id` |
| `conta_pagar_id` | `uuid?` | FK → `me_contas_pagar.id` |

**RLS:** ❌ Desabilitado

---

### Caixa (`cx_*`)

#### `public.cx_classe_movimentacao_caixa` — Classes (Entrada/Saída)

| Coluna | Tipo | Observação |
|---|---|---|
| `id_classe` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | FK → `me_empresa.id` |
| `nome_classe` | `text NOT NULL` | |

**RLS:** ❌ Desabilitado

---

#### `public.cx_tipo_movimentacao_caixa` — Tipos por classe

| Coluna | Tipo | Observação |
|---|---|---|
| `id_tipo` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | |
| `id_classe` | `integer?` | FK → `cx_classe_movimentacao_caixa.id_classe` |
| `nome_tipo` | `text NOT NULL` | |

**RLS:** ❌ Desabilitado

---

#### `public.cx_categorias_movimentacao_caixa` — Categorias por tipo

| Coluna | Tipo | Observação |
|---|---|---|
| `id_categoria` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | |
| `id_tipo` | `integer?` | FK → `cx_tipo_movimentacao_caixa.id_tipo` |
| `nome_categoria` | `text NOT NULL` | |

**RLS:** ❌ Desabilitado

---

#### `public.cx_contas` — Contas de caixa

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `nome` | `text NOT NULL` | |
| `tipo` | `text NOT NULL` | |
| `saldo_inicial` | `numeric?` | `default 0` |
| `ativo` | `boolean?` | `default true` |
| `status` | `text?` | `default 'ABERTO'` |

**RLS:** ✅ Ativo

---

#### `public.cx_movimentacao_caixa` — Lançamentos de caixa

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `conta_id` | `uuid?` | FK → `cx_contas.id` |
| `categoria_id` | `integer?` | FK → `cx_categorias_movimentacao_caixa.id_categoria` |
| `tipo` | `text NOT NULL` | |
| `valor` | `numeric NOT NULL` | |
| `data_competencia` | `date NOT NULL` | |
| `data_vencimento` | `date NOT NULL` | |
| `data_pagamento` | `date?` | |
| `descricao` | `text NOT NULL` | |
| `status` | `text NOT NULL` | |
| `created_by` | `uuid?` | FK → `auth.users.id` |

**RLS:** ✅ Ativo

---

### Financeiro Recorrente (`fn_*`)

#### `public.fn_categoria` — Categorias para movimentos recorrentes

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `nome` | `text NOT NULL` | |
| `tipo` | `text NOT NULL` | |

**RLS:** ✅ Ativo

---

#### `public.fn_conta` — Contas para movimentos recorrentes

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `nome` | `text NOT NULL` | |
| `tipo` | `text NOT NULL` | |
| `saldo_inicial` | `numeric?` | `default 0` |
| `status` | `text?` | `default 'ativo'` |

**RLS:** ✅ Ativo

---

#### `public.fn_movimento` — Movimentos financeiros gerados

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `descricao` | `text NOT NULL` | |
| `valor` | `numeric NOT NULL` | |
| `tipo` | `text NOT NULL` | |
| `status` | `text?` | `default 'pendente'` |
| `data_vencimento` | `date NOT NULL` | |
| `data_pagamento` | `date?` | |
| `categoria_id` | `bigint?` | FK → `fn_categoria.id` |
| `cliente_id` | `uuid?` | FK → `me_cliente.id` |
| `conta_id` | `uuid?` | FK → `fn_conta.id` |
| `recorrencia_id` | `uuid?` | FK → `fn_movimento_recorrencia.id` |
| `eh_parcelado` | `boolean?` | |
| `parcela_numero`, `parcela_total` | `integer?` | |
| `grupo_parcelamento` | `uuid?` | |
| `eh_recorrente` | `boolean?` | |

**RLS:** ✅ Ativo

---

#### `public.fn_movimento_recorrencia` — Regras de recorrência

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `descricao` | `text NOT NULL` | |
| `valor` | `numeric NOT NULL` | |
| `tipo` | `text NOT NULL` | |
| `dia_vencimento` | `integer NOT NULL` | |
| `tipo_recorrencia` | `text NOT NULL` | `'mensal'` ou `'fixa_12_meses'` |
| `meses_restantes` | `integer?` | |
| `ativo` | `boolean?` | `default true` |
| `categoria_id` | `integer?` | FK → `fn_categoria.id` |
| `conta_id` | `uuid?` | FK → `fn_conta.id` |

**RLS:** ❌ Desabilitado

---

## 8. Agenda (`agd_*`)

### `public.agd_status_agendamento` — Status de agendamento

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | FK → `me_empresa.id` |
| `status` | `text NOT NULL` | Ex: Confirmado, Cancelado, Realizado |

**RLS:** ❌ Desabilitado

---

### `public.agd_agendamentos` — Agendamentos

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `colaborador_id` | `uuid NOT NULL` | FK → `me_usuario.id` |
| `cliente_id` | `uuid?` | FK → `me_cliente.id` |
| `data_agendamento` | `date NOT NULL` | |
| `hora_inicio` | `time NOT NULL` | |
| `hora_fim` | `time NOT NULL` | |
| `observacao` | `text?` | |
| `status` | `text?` | `default 'agendado'` |

**RLS:** ❌ Desabilitado

---

### `public.agd_preferencias` — Preferências da agenda

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `intervalo_minutos` | `integer NOT NULL` | `default 30` |

**RLS:** ❌ Desabilitado

---

### `public.agd_horarios_empresa` — Horários de funcionamento (agenda)

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `dia_semana` | `integer NOT NULL` | 0=domingo, 1=segunda... |
| `aberto` | `boolean?` | `default true` |
| `hora_inicio` | `time?` | `default '08:00'` |
| `hora_fim` | `time?` | `default '18:00'` |

**RLS:** ❌ Desabilitado

---

### `public.agd_config_colaboradores` — Configuração por colaborador

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `colaborador_id` | `uuid NOT NULL` | |
| `agenda_habilitada` | `boolean?` | `default true` |

**RLS:** ❌ Desabilitado

---

### `public.agd_bloqueios_fixos` — Bloqueios na agenda

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `dia_semana` | `integer NOT NULL` | |
| `hora_inicio` | `time NOT NULL` | |
| `hora_fim` | `time NOT NULL` | |
| `titulo` | `text NOT NULL` | Motivo do bloqueio |

**RLS:** ❌ Desabilitado

---

### `public.agd_ft_horarios_modelo` — Modelos de horários

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | FK → `me_empresa.id` |
| `horario_modelo_id` | `integer?` | |

**RLS:** ❌ Desabilitado

---

## 9. Estoque (`est_*`)

### `public.est_compra` — Compras / entrada de estoque

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `fornecedor_id` | `uuid NOT NULL` | FK → `me_fornecedor.id` |
| `data_compra` | `timestamptz NOT NULL` | `default now()` |
| `status` | `text?` | `default 'PENDENTE'` |
| `valor_total` | `numeric?` | `default 0` |
| `nota_fiscal` | `text?` | |

**RLS:** ✅ Ativo

---

### `public.est_compra_item` — Itens da compra

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `compra_id` | `uuid NOT NULL` | FK → `est_compra.id` |
| `produto_id` | `integer NOT NULL` | FK → `me_produto.id` |
| `quantidade` | `numeric NOT NULL` | |
| `valor_unitario` | `numeric NOT NULL` | |

**RLS:** ✅ Ativo

---

### `public.est_movimentacao` — Movimentações de estoque

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `produto_id` | `integer NOT NULL` | FK → `me_produto.id` |
| `tipo` | `text NOT NULL` | `'entrada'` ou `'saida'` |
| `quantidade` | `numeric NOT NULL` | |
| `motivo` | `text?` | |
| `usuario_id` | `uuid?` | FK → `auth.users.id` |

**RLS:** ✅ Ativo

---

## 10. Produtos, Serviços, Vendas e Cadastros de Apoio

### Produtos

#### `public.me_produto` — Catálogo de produtos

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | FK → `me_empresa.id` |
| `nome_produto` | `text?` | |
| `preco` | `numeric?` | |
| `preco_varejo` | `numeric?` | |
| `preco_custo` | `numeric?` | |
| `sku` | `text?` | |
| `codigo_barras` | `text?` | |
| `estoque_atual` | `integer?` | `default 0` |
| `categoria_id` | `integer?` | FK → `me_categoria.id_categoria` |
| `subcategoria_id` | `integer?` | FK → `me_subcategoria.id_subcategoria` |
| `unidade_medida_id` | `integer?` | FK → `me_unidade_medida.id` |
| `tipo` | `text?` | `default 'simples'` |
| `opcoes_config` | `jsonb?` | Para produtos com variações |
| `ativo` | `boolean?` | `default true` |
| `exibir_vitrine` | `boolean?` | `default false` |
| `foto_url` | `text?` | |
| `descricao` | `text?` | |

**RLS:** ❌ Desabilitado

---

#### `public.me_produto_variacao` — Variações de produto

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `produto_pai_id` | `integer NOT NULL` | FK → `me_produto.id` |
| `sku` | `text?` | |
| `preco_varejo` | `numeric?` | `default 0` |
| `preco_custo` | `numeric?` | `default 0` |
| `estoque_atual` | `integer?` | `default 0` |
| `atributos` | `jsonb?` | Ex: `{"cor": "azul", "tamanho": "G"}` |
| `foto_url` | `text?` | |

**RLS:** ❌ Desabilitado

---

#### `public.me_produto_imagem` — Imagens de produto

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `produto_id` | `bigint NOT NULL` | FK → `me_produto.id` |
| `imagem_url` | `text NOT NULL` | |
| `ordem_exibicao` | `integer?` | `default 0` |

**RLS:** ❌ Desabilitado

---

#### `public.me_categoria` — Categorias de produtos/serviços

| Coluna | Tipo | Observação |
|---|---|---|
| `id_categoria` | `integer PK` | |
| `empresa_id` | `uuid?` | FK → `me_empresa.id` |
| `nome_categoria` | `varchar NOT NULL` | |

**RLS:** ❌ Desabilitado

---

#### `public.me_subcategoria` — Subcategorias

| Coluna | Tipo | Observação |
|---|---|---|
| `id_subcategoria` | `integer PK` | |
| `empresa_id` | `uuid?` | |
| `id_categoria` | `integer NOT NULL` | FK → `me_categoria.id_categoria` |
| `nome_subcategoria` | `varchar NOT NULL` | |

**RLS:** ❌ Desabilitado

---

### Serviços

#### `public.me_servico` — Catálogo de serviços

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | FK → `me_empresa.id` |
| `nome_servico` | `text NOT NULL` | |
| `sku` | `text?` | |
| `categoria_id` | `integer?` | FK → `me_categoria.id_categoria` |
| `subcategoria_id` | `integer?` | FK → `me_subcategoria.id_subcategoria` |
| `unidade_medida_id` | `integer?` | FK → `me_unidade_medida.id` |
| `preco` | `numeric?` | `default 0` |
| `preco_custo` | `numeric?` | `default 0` |
| `preco_varejo` | `numeric?` | `default 0` |
| `duracao_minutos` | `integer?` | `default 30` |
| `ativo` | `boolean?` | `default true` |
| `descricao` | `text?` | |

**RLS:** ❌ Desabilitado

---

#### `public.me_servico_imagem` — Imagens de serviço

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `bigint PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `servico_id` | `bigint NOT NULL` | FK → `me_servico.id` |
| `imagem_url` | `text NOT NULL` | |
| `ordem_exibicao` | `integer?` | `default 1` |

**RLS:** ❌ Desabilitado

---

### Vendas

#### `public.me_venda` — Vendas de produtos

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid?` | |
| `cliente_id` | `uuid?` | |
| `usuario_id` | `uuid?` | FK → `me_usuario.id` |
| `valor_total` | `numeric NOT NULL` | |
| `valor_desconto` | `numeric NOT NULL` | `default 0` |
| `status_venda` | `text NOT NULL` | `default 'concluída'` |
| `forma_pagamento` | `integer?` | FK → `me_forma_pagamento.id` |
| `conta_id` | `uuid?` | FK → `cx_contas.id` |
| `canal_venda` | `text?` | |
| `tipo_venda` | `text?` | |
| `npedido` | `integer?` | Número do pedido |

**RLS:** ✅ Ativo

---

#### `public.me_itens_venda` — Itens da venda de produtos

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `venda_id` | `uuid NOT NULL` | FK → `me_venda.id` |
| `produto_id` | `integer?` | FK → `me_produto.id` |
| `quantidade` | `integer NOT NULL` | `default 1` |
| `preco_unitario` | `numeric NOT NULL` | |
| `subtotal` | `numeric?` | |
| `desconto` | `numeric NOT NULL` | `default 0` |
| `nome_produto` | `text?` | |
| `sku` | `text?` | |

**RLS:** ✅ Ativo

---

#### `public.me_venda_servicos` — Vendas de serviços

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid?` | |
| `cliente_id` | `uuid?` | FK → `me_cliente.id` |
| `usuario_id` | `uuid?` | FK → `auth.users.id` |
| `valor_total` | `numeric?` | |
| `valor_desconto` | `numeric?` | |
| `forma_pagamento` | `integer?` | FK → `me_forma_pagamento.id` |
| `status_venda` | `text?` | |
| `canal_venda` | `text?` | |

**RLS:** ✅ Ativo

---

#### `public.me_venda_servicos_itens` — Itens da venda de serviços

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `venda_id` | `uuid?` | FK → `me_venda_servicos.id` |
| `servico_id` | `integer?` | FK → `me_servico.id` |
| `quantidade` | `integer?` | |
| `preco_unitario` | `numeric?` | |
| `subtotal` | `numeric?` | |
| `nome_servico` | `text?` | |
| `desconto` | `numeric?` | |

**RLS:** ✅ Ativo

---

### Cadastros de Apoio

#### `public.me_cliente` — Clientes

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid?` | |
| `nome_cliente` | `text NOT NULL` | |
| `telefone` | `text?` | |
| `email` | `text?` | |
| `documento` | `text?` | |
| `cpf_cnpj` | `text?` | |
| `data_nascimento` | `date?` | |
| `ativo` | `boolean?` | `default true` |
| `endereco`, `cidade`, `estado`, `cep`, `bairro` | `text?` | |
| `observacoes` | `text?` | |
| `foto_url` | `text?` | |
| `origem` | `text?` | |

**RLS:** ❌ Desabilitado  
**Referenciado por:** vendas, CRM, agenda, financeiro, chat, atendimentos.

---

#### `public.me_fornecedor` — Fornecedores

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `uuid PK` | |
| `empresa_id` | `uuid NOT NULL` | |
| `nome_fornecedor` | `text NOT NULL` | |
| `razao_social` | `text?` | |
| `cpf_cnpj` | `text?` | |
| `contato_nome` | `text?` | |
| `telefone` | `text?` | |
| `email` | `text?` | |
| `endereco`, `cidade`, `estado`, `cep` | `text?` | |
| `ativo` | `boolean?` | `default true` |

**RLS:** ❌ Desabilitado

---

#### `public.me_forma_pagamento` — Formas de pagamento

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | |
| `nome` | `text NOT NULL` | Ex: Dinheiro, Cartão, Pix |

**RLS:** ❌ Desabilitado

---

#### `public.me_unidade_medida` — Unidades de medida

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | |
| `nome` | `text NOT NULL` | |
| `sigla` | `text NOT NULL` | Ex: un, kg, m, h |

**RLS:** ❌ Desabilitado

---

#### `public.me_horario_funcionamento` — Horários de funcionamento

| Coluna | Tipo | Observação |
|---|---|---|
| `id` | `integer PK` | `serial` |
| `empresa_id` | `uuid?` | |
| `dia_semana` | `text?` | |
| `dia_semana_abrev` | `text?` | |
| `hora_ini` | `time?` | |
| `hora_fim` | `time?` | |

**RLS:** ❌ Desabilitado

---

## 11. Principais Chaves Estrangeiras e Dependências Entre Domínios

```
auth.users
  └── me_usuario.id (1:1 — mesmo UUID)
       ├── me_usuario.empresa_id → me_empresa.id
       ├── me_usuario.cargo → me_cargo.id
       ├── atd_conversas.assigned_to
       ├── atd_mensagens.sender_id
       ├── agd_agendamentos.colaborador_id
       └── me_venda.usuario_id

me_empresa (raiz do multi-tenant)
  ├── me_usuario, me_cargo, me_empresa_endereco
  ├── me_produto, me_servico, me_cliente, me_fornecedor
  ├── me_categoria, me_subcategoria, me_unidade_medida
  ├── me_forma_pagamento, me_horario_funcionamento
  ├── crm_leads, crm_etapas, crm_origem
  ├── crm_chat_config, crm_chat_conversas, crm_chat_respostas_rapidas
  ├── mel_consultoria_config, mel_projetos
  ├── atd_config, atd_conversas, atd_respostas_rapidas
  ├── me_conta, me_categoria_financeira
  ├── me_contas_receber, me_contas_pagar, me_movimentacao_financeira
  ├── cx_*, fn_*
  ├── est_compra, est_movimentacao
  ├── agd_*
  ├── me_venda, me_venda_servicos, me_itens_venda
  ├── unq_empresa_modulos, me_modulo_cargo, me_modulo_ativo
  └── (CASCADE na deleção)

me_cliente
  ├── crm_oportunidades, crm_atendimentos, crm_chat_conversas
  ├── agd_agendamentos, atd_conversas
  ├── me_venda_servicos, me_contas_receber
  └── fn_movimento

crm_leads
  ├── crm_oportunidades
  └── crm_chat_conversas

crm_oportunidades
  ├── crm_oportunidade_produtos → me_produto
  └── crm_atividades

atd_conversas
  └── atd_mensagens

crm_chat_conversas
  └── crm_chat_mensagens

me_produto
  ├── me_produto_variacao, me_produto_imagem
  ├── est_movimentacao, est_compra_item
  ├── me_itens_venda
  └── crm_oportunidade_produtos

me_servico
  ├── me_servico_imagem
  └── me_venda_servicos_itens

me_venda → me_itens_venda → me_produto
me_venda_servicos → me_venda_servicos_itens → me_servico

me_contas_receber → me_movimentacao_financeira
me_contas_pagar → me_movimentacao_financeira

fn_movimento_recorrencia → fn_movimento
```

---

## 12. ⚠️ Alerta de Segurança: RLS Desabilitado

**52 tabelas `public.*` estão com RLS desabilitado.** Isso expõe todos os dados para qualquer requisição com a `anon key` do Supabase. As tabelas críticas incluem:

| Grupo | Tabelas afetadas |
|---|---|
| **Core/Tenant** | `me_empresa`, `me_cargo`, `me_usuario`, `me_horario_funcionamento` |
| **CRM** | `crm_leads`, `crm_etapas`, `crm_oportunidades`, `crm_oportunidade_produtos`, `crm_atendimentos`, `crm_atividades`, `crm_origem` |
| **Melissa** | `mel_consultoria_config`, `mel_consultoria`, `mel_chat`, `mel_chat_buffer`, `mel_projetos` |
| **ATD** | `atd_config`, `atd_conversas`, `atd_mensagens`, `atd_respostas_rapidas`, `_migracao_atd_log` |
| **Financeiro** | `me_conta`, `me_categoria_financeira`, `me_contas_receber`, `me_contas_pagar`, `me_movimentacao_financeira`, `cx_classe_*`, `cx_tipo_*`, `cx_categorias_*`, `fn_movimento_recorrencia` |
| **Agenda** | Todas as `agd_*` |
| **Produtos/Serviços** | `me_produto`, `me_produto_variacao`, `me_produto_imagem`, `me_servico`, `me_servico_imagem`, `me_categoria`, `me_subcategoria`, `me_cliente`, `me_fornecedor`, `me_forma_pagamento`, `me_unidade_medida` |
| **Módulos** | `me_modulo_cargo`, `me_modulo_ativo` |

**Tabelas com RLS ativo (protegidas):** `crm_chat_config`, `crm_chat_conversas`, `crm_chat_mensagens`, `crm_chat_respostas_rapidas`, `est_compra`, `est_compra_item`, `est_movimentacao`, `me_venda`, `me_itens_venda`, `me_venda_servicos`, `me_venda_servicos_itens`, `cx_contas`, `cx_movimentacao_caixa`, `fn_categoria`, `fn_conta`, `fn_movimento`, `mel_chat_custos`, `unq_modulos_sistema`, `unq_empresa_modulos`, `me_empresa_endereco`.

---

## 13. Tabelas a Ignorar no MVP (Backlog Pós-MVP)

Para um MVP focado em **CRM + Chat + Melissa + Autenticação multi-tenant**, as seguintes tabelas podem ser ignoradas inicialmente:

| Domínio | Tabelas | Motivo |
|---|---|---|
| **Financeiro completo** | `me_conta`, `me_categoria_financeira`, `me_contas_receber`, `me_contas_pagar`, `me_movimentacao_financeira`, `cx_*`, `fn_*` | Módulo financeiro completo — backlog |
| **Estoque** | `est_compra`, `est_compra_item`, `est_movimentacao` | Controle de estoque — backlog |
| **Vendas de produtos** | `me_venda`, `me_itens_venda` | PDV — backlog |
| **Vendas de serviços** | `me_venda_servicos`, `me_venda_servicos_itens` | Venda de serviços — backlog |
| **Agenda** | Todas as `agd_*` | Módulo de agenda — backlog |
| **Produtos (completo)** | `me_produto_variacao`, `me_produto_imagem`, `me_servico_imagem` | Variações e imagens — podem vir depois |
| **ATD legado** | `atd_config`, `atd_conversas`, `atd_mensagens`, `atd_respostas_rapidas`, `_migracao_atd_log` | Substituído pelo CRM Chat |
| **Teste** | `teste_opencode`, `teste_03` | Apenas para testes |

**Tabelas essenciais para o MVP:**

- `me_empresa`, `me_usuario`, `me_cargo`, `me_empresa_endereco`
- `unq_modulos_sistema`, `unq_empresa_modulos`, `me_modulo_cargo`, `me_modulo_ativo`
- `crm_leads`, `crm_etapas`, `crm_oportunidades`, `crm_oportunidade_produtos`, `crm_atendimentos`, `crm_atividades`, `crm_origem`
- `crm_chat_conversas`, `crm_chat_mensagens`, `crm_chat_config`, `crm_chat_respostas_rapidas`
- `mel_consultoria_config`, `mel_consultoria`, `mel_chat`, `mel_chat_buffer`, `mel_chat_custos`, `mel_projetos`
- `me_cliente`, `me_produto` (catálogo básico), `me_servico` (catálogo básico), `me_categoria`, `me_subcategoria`, `me_forma_pagamento`, `me_unidade_medida`, `me_fornecedor`
- `me_horario_funcionamento`

---

## 14. Próximos Passos Sugeridos

1. Obter código das Edge Functions `crm-webhook-proxy`, `webhook-whatsapp` e `send-whatsapp-message`.
2. Validar estratégia de ligação entre `parceiro_id` (Base UNIQ) e `me_empresa.id` (protótipo).
3. Habilitar RLS nas tabelas essenciais do MVP com policies por `empresa_id`.
4. Aplicar migration local `001_initial_schema.sql` e criar mecanismo de ligação.
5. Implementar login real e fluxo de cadastro/convite.
