# Tracking — Base UNIQ MVP

> Arquivo vivo de acompanhamento do desenvolvimento. Consulte no início de cada sessão para entender o estado atual.

---

## Visão Geral

**Objetivo:** Entregar a Base UNIQ (MVP) para os 4 primeiros fundadores em até 2 meses.

**Arquitetura:**
- Frontend: Next.js 14 (App Router) na Vercel
- Backend: Next.js API Routes + Server Actions
- Banco: Supabase (Postgres + Auth + RLS)
- IA/Agente: n8n + OpenRouter (fluxos já existentes)
- WhatsApp/Instagram: Evolution API

**Documentos de referência:**
- `CONTEXTO_UNIQ.md` — contexto estratégico da UNIQ
- `DESIGN.md` — design system da Base UNIQ
- `docs/design/` — ativos visuais (logo, avatar, paleta)

---

## Status Atual

| Item | Status | Observação |
|------|--------|------------|
| Contexto estratégico | ✅ Concluído | Registrado em `CONTEXTO_UNIQ.md` |
| Identidade mínima | ✅ Concluído | Cores, tipografia, avatar, tom de voz |
| Design system | ✅ Concluído | `DESIGN.md` criado |
| Definição da Melissa | ✅ Concluído | Persona, papéis, limites registrados |
| Arquitetura técnica | ✅ Concluído | Stack definida, custos estimados |
| Setup do projeto Next.js | ✅ Concluído | Semana 1 — projeto local pronto, build e lint OK |
| Conexão com Supabase | ✅ Concluído | Clientes browser/server, middleware e `.env.local` configurados |
| Middleware de autenticação | ✅ Concluído | Protege `/dashboard` e `/chat`; redireciona logados de `/login` |
| Schema local inicial | ✅ Concluído | Migration `001_initial_schema.sql` com 4 tabelas + RLS + seed *(não será aplicada — ver decisão abaixo)* |
| Autenticação real (login/cadastro) | ✅ Concluído | Login real implementado usando `me_usuario`/`me_empresa`; build e lint OK |
| Cadastro de parceiro/usuário | ⬜ Pendente | Fluxo de convite/criação de empresa e usuário |
| Push para repositório GitHub `uniqempresas/uniq` | ✅ Concluído | Feito via token PAT; remote configurado para pushes futuros |
| Deploy inicial na Vercel | 🟡 Em progresso | Aguardando configuração na Vercel pelo usuário |
| Migration local aplicada no Supabase | ❌ Não aplicar | Decisão do parceiro: reaproveitar tabelas do protótipo (`me_empresa`, `me_usuario`, etc.) |
| **Mapeamento do banco de protótipo** | ✅ **Concluído** | **Documentado em `docs/banco-prototipo.md` — sem alterações no Supabase** |
| Dashboard inicial + Sidebar | ⬜ Pendente | Semana 2 |
| Chat com Melissa (Base UNIQ) | ⬜ Pendente | Semana 2 — banco de protótipo já tem tabelas `mel_*` e `crm_chat_*` |
| Integração n8n ↔ Base UNIQ | 🟡 Parcial no banco | Semana 3 — banco de protótipo já tem tabelas e Edge Functions; frontend não existe |
| CRM leve de leads | 🟡 Parcial no banco | Semana 3 — tabelas `crm_*` já existem; tela não existe |
| Visualizador de conversas WhatsApp | 🟡 Parcial no banco | Semana 4 — tabelas `atd_*` e `crm_chat_*` já existem; tela não existe |
| Responder pelo Base UNIQ | 🟡 Parcial no banco | Semana 4 — Edge Function `send-whatsapp-message` já existe; endpoint no Next.js não existe |
| Testes com 1 fundador | ⬜ Pendente | Semana 5 |
| Ajustes + expansão 4 fundadores | ⬜ Pendente | Semana 6 |

---

## ⚠️ Discrepância Importante: Código vs. Supabase

O banco de dados do Supabase (herdado do protótipo) está **muito à frente do frontend Next.js**:

- **93 migrations aplicadas** no Supabase, contra **1 migration local** (`001_initial_schema.sql`).
- **91 tabelas** no banco, incluindo CRM, chat da Melissa, WhatsApp, financeiro, estoque, agenda, vendas e módulos.
- **4 Edge Functions ativas**: `create-user`, `crm-webhook-proxy`, `webhook-whatsapp`, `send-whatsapp-message`.
- **52 tabelas públicas estão com RLS desabilitado** — isso é um risco de segurança a ser tratado em sprint dedicada.

**Consequência prática:** o protótipo já possui estrutura para Semanas 3 e 4, mas o frontend ainda está na Semana 1.

---

## 🎯 Decisões Estratégicas

Decisão aprovada pelo parceiro em 05/08/2026:

1. **O banco de protótipo tem apenas dados de teste** ✅ — sem risco de perda de dados reais.
2. **O Supabase de protótipo só foi usado pelo parceiro** ✅ — pode ser usado/reorganizado livremente.
3. **Existem 2 ou 3 empresas de teste criadas** ✅ — volume pequeno, fácil de mapear.
4. **Nenhum fundador usa a Base UNIQ ainda** ✅ — não há histórico a preservar.
5. **Segurança não é o foco agora** ✅ — haverá uma sprint dedicada a RLS e segurança mais à frente.

**Estratégia escolhida: Híbrida (C), com uso direto das tabelas do protótipo**

> Reaproveitar as tabelas de negócio do protótipo (`crm_*`, `mel_*`, `atd_*`, etc.) **e usar diretamente as tabelas de core do protótipo** (`me_empresa` como parceiro, `me_usuario` como usuário, `unq_modulos_sistema`/`unq_empresa_modulos` como módulos). Não criar tabelas novas (`parceiros`, `usuarios`, etc.) salvo se for absolutamente necessário e não houver correspondente. Campos faltantes podem ser adicionados às tabelas existentes.

**Restrição atual:** não criar nem alterar tabelas no Supabase nesta fase. Apenas mapear. Alterações no banco só na sprint de segurança ou quando explicitamente necessárias para o MVP.

---

## 📋 Plano de Fases

### Fase 0 — Mapeamento do Protótipo (concluída)
**Objetivo:** saber exatamente o que existe no Supabase antes de tocar em qualquer coisa.

- [x] Congelar alterações no Supabase protótipo.
- [x] Fazer backup/ponto de restauração do projeto Supabase.
- [x] Documentar tabelas do protótipo por domínio:
  - [x] Core/tenant: `me_empresa`, `me_usuario`, `me_cargo`, `unq_modulos_sistema`, `unq_empresa_modulos`
  - [x] CRM: `crm_leads`, `crm_etapas`, `crm_oportunidades`, `crm_chat_conversas`, `crm_chat_mensagens`, `crm_chat_config`
  - [x] Melissa: `mel_consultoria_config`, `mel_consultoria`, `mel_chat`, `mel_projetos`
  - [x] WhatsApp/Atendente: `atd_config`, `atd_conversas`, `atd_mensagens`, `crm_chat_*`
  - [x] Financeiro, estoque, agenda, produtos/serviços/vendas
- [x] Documentar Edge Functions existentes: propósito, entradas, saídas, JWT *(código de 3 functions não acessível — resolver na Fase 3)*.
- [x] Identificar a chave de ligação entre `parceiro_id` (Base UNIQ) e `me_empresa.id` (protótipo).
- [x] Listar quais tabelas do protótipo serão reaproveitadas por domínio.
- [x] Anotar dependências e FKs críticas.

**Entregável:** ✅ `docs/banco-prototipo.md` criado com mapeamento completo.

---

### Fase 1 — Core da Base UNIQ (próxima)
**Objetivo:** fazer login real e usar as tabelas existentes do protótipo como core.

- [ ] Implementar login real em `src/app/(auth)/login/page.tsx` usando `supabase.auth.signInWithPassword()`.
- [ ] Após login, buscar perfil em `me_usuario` e validar vínculo com `me_empresa`.
- [ ] Ajustar middleware para validar `empresa_id` + `role`/`cargo` nas rotas protegidas.
- [ ] Criar server actions/helpers de autenticação baseados em `me_usuario` e `me_empresa`.
- [ ] Criar fluxo de cadastro/convite de parceiro — inserir em `me_empresa`, `me_cargo` e `me_usuario` (possivelmente via Edge Function `create-user`).
- [ ] Adicionar campos faltantes nas tabelas existentes **somente se necessário** (ex: papel/role, status ativo).
- [ ] (Opcional) Adicionar tabela auxiliar `parceiro_modulos` se `unq_empresa_modulos` não atender.

**Entregável:** login e cadastro funcionando com isolamento por `me_empresa.id`.

> **Nota:** a migration `001_initial_schema.sql` local **não será aplicada**. Ela serviu como referência de arquitetura, mas o schema real é o do protótipo.

---

### Fase 2 — Dashboard + Chat da Melissa
**Objetivo:** parceiro loga e vê a Melissa na Base UNIQ.

- [ ] Criar layout padrão (sidebar escura + conteúdo claro).
- [ ] Criar dashboard inicial do parceiro.
- [ ] Criar tela de chat com a Melissa.
- [ ] Exibir avatar da Melissa nas mensagens.
- [ ] Salvar mensagens do chat no Supabase usando tabelas do protótipo (`mel_chat`, etc.) via camada de ligação.
- [ ] Criar painel de módulos ativos/pendentes.

**Entregável:** parceiro consegue logar, conversar com a Melissa e ver módulos.

---

### Fase 3 — Integração n8n e CRM Leve
**Objetivo:** Base UNIQ conversa com fluxos do n8n.

- [ ] Criar API routes no Next.js para receber dados do n8n.
- [ ] Auditar Edge Functions `crm-webhook-proxy` e `create-user`.
- [ ] Criar tela de CRM leve (lista de leads) usando `crm_leads`.
- [ ] Criar tela de detalhes do lead.
- [ ] Sincronizar leads entre Supabase e n8n.

**Entregável:** mensagens e leads fluem entre n8n e Base UNIQ.

---

### Fase 4 — WhatsApp: Visualizar e Responder
**Objetivo:** parceiro vê e intervém nas conversas da Melissa no WhatsApp.

- [ ] Criar tela de visualização de conversas usando `atd_*` e `crm_chat_*`.
- [ ] Exibir histórico de mensagens por lead/cliente.
- [ ] Permitir que o parceiro responda pela Base UNIQ (usar Edge Function `send-whatsapp-message`).
- [ ] Enviar resposta do parceiro de volta para o WhatsApp via n8n.
- [ ] Marcar conversas como atribuídas ao parceiro ou à Melissa.
- [ ] Notificações de novas mensagens.

**Entregável:** funcionalidade estilo Chatwoot dentro da Base UNIQ.

---

### Fase 5 — Teste com 1 Fundador
**Objetivo:** validar com uso real antes de escalar.

- [ ] Onboardar 1 fundador.
- [ ] Configurar WhatsApp do fundador na Evolution API.
- [ ] Acompanhar conversas e uso durante a semana.
- [ ] Coletar feedback diário.
- [ ] Registrar bugs e melhorias no backlog.
- [ ] Ajustar fluxos da Melissa conforme feedback.

**Entregável:** 1 fundador usando ativamente.

---

### Fase 6 — Ajustes e Expansão
**Objetivo:** preparar para os 4 fundadores.

- [ ] Corrigir bugs encontrados.
- [ ] Refinar prompt da Melissa.
- [ ] Melhorar onboarding do parceiro.
- [ ] Documentar processo de ativação de novo parceiro.
- [ ] Expandir para os 4 fundadores.
- [ ] Criar painel administrativo básico da UNIQ.

**Entregável:** 4 fundadores ativos na Base UNIQ.

---

## Semana 1 — Setup e Fundação

**Objetivo:** ter o projeto rodando na Vercel com login funcional.

### Tarefas
- [ ] Criar repositório no GitHub *(repositório criado em https://github.com/uniqempresas/uniq — push pendente por questão de autenticação da conta correta)*
- [x] Inicializar projeto Next.js 14 com App Router
- [x] Configurar Tailwind CSS com cores do `DESIGN.md`
- [x] Instalar e configurar `shadcn/ui`
- [x] Configurar conexão com Supabase (`@supabase/ssr`) — clientes e middleware prontos, `.env.local` configurado
- [x] Criar middleware de autenticação — protege rotas internas e redireciona logados
- [x] Criar schema inicial local no Supabase — migration `001_initial_schema.sql` criada como **referência de arquitetura**, mas **não será aplicada** no banco real
- [ ] Implementar autenticação real (login/cadastro) com Supabase Auth usando tabelas do protótipo (`me_empresa`, `me_usuario`) — tela criada com stub, falta integração real
- [x] Decidir reaproveitamento do banco de protótipo — **decisão: usar tabelas existentes do protótipo**
- [ ] Deploy inicial na Vercel *(próximo passo externo)*
- [ ] Testar login em produção *(próximo passo externo)*

> **Nota técnica — push GitHub:** o push inicial falhou porque o `gh` local está autenticado como `hqgrafica-uniq`, mas o repositório `uniqempresas/uniq` exige o usuário `uniqempresas`. Resolver no final da sprint.

> **Nota técnica — banco de protótipo:** o Supabase já contém tabelas equivalentes ao schema local (`me_empresa`, `me_usuario`, `unq_modulos_sistema`, `unq_empresa_modulos`). Decisão do parceiro: **usar as tabelas existentes do protótipo** em vez de aplicar a migration local. A migration `001_initial_schema.sql` permanece como referência de arquitetura.

**Entregável:** URL pública com tela de login funcional.

---

## Semana 2 — Dashboard e Chat da Melissa

**Objetivo:** o parceiro loga e vê a Melissa na Base UNIQ.

### Tarefas
- [ ] Criar layout padrão (sidebar escura + conteúdo claro)
- [ ] Aplicar identidade UNIQ (cores, tipografia, avatar)
- [ ] Criar dashboard inicial do parceiro
- [ ] Criar tela de chat com a Melissa (modo consultoria)
- [ ] Exibir avatar da Melissa nas mensagens
- [ ] Salvar mensagens do chat no Supabase *(banco de protótipo já tem `mel_chat`, `mel_consultoria_config`, etc.)*
- [ ] Criar painel de módulos ativos/pendentes

**Entregável:** parceiro consegue logar, conversar com a Melissa e ver módulos.

---

## Semana 3 — Integração com n8n e CRM

**Objetivo:** a Base UNIQ conversa com o fluxo do n8n.

### Tarefas
- [ ] Criar webhooks no Next.js para receber dados do n8n *(banco de protótipo já tem `crm-webhook-proxy` Edge Function)*
- [ ] Ajustar fluxo `CONSULTORIA_MEL uat4` para enviar mensagens para a Base UNIQ
- [ ] Criar endpoint para o n8n consultar dados do parceiro
- [ ] Criar tela de CRM leve (lista de leads) *(banco de protótipo já tem `crm_leads`, `crm_etapas`, etc.)*
- [ ] Criar tela de detalhes do lead
- [ ] Sincronizar leads entre Supabase e n8n

**Entregável:** mensagens e leads fluem entre n8n e Base UNIQ.

---

## Semana 4 — Conversas do WhatsApp

**Objetivo:** o parceiro vê e pode intervir nas conversas da Melissa no WhatsApp.

### Tarefas
- [ ] Criar tela de visualização de conversas do WhatsApp *(banco de protótipo já tem `atd_conversas`, `crm_chat_conversas`, etc.)*
- [ ] Exibir histórico de mensagens por lead/cliente
- [ ] Permitir que o parceiro responda pela Base UNIQ *(Edge Function `send-whatsapp-message` já existe)*
- [ ] Enviar resposta do parceiro de volta para o WhatsApp via n8n
- [ ] Marcar conversas como atribuídas ao parceiro ou à Melissa
- [ ] Notificações de novas mensagens

**Entregável:** funcionalidade estilo Chatwoot dentro da Base UNIQ.

---

## Semana 5 — Teste com 1 Fundador

**Objetivo:** validar com uso real antes de escalar.

### Tarefas
- [ ] Onboardar 1 fundador
- [ ] Configurar WhatsApp do fundador na Evolution API
- [ ] Acompanhar conversas e uso durante a semana
- [ ] Coletar feedback diário
- [ ] Registrar bugs e melhorias no backlog
- [ ] Ajustar fluxos da Melissa conforme feedback

**Entregável:** 1 fundador usando ativamente.

---

## Semana 6 — Ajustes e Expansão

**Objetivo:** preparar para os 4 fundadores.

### Tarefas
- [ ] Corrigir bugs encontrados
- [ ] Refinar prompt da Melissa
- [ ] Melhorar onboarding do parceiro
- [ ] Documentar processo de ativação de novo parceiro
- [ ] Expandir para os 4 fundadores
- [ ] Criar painel administrativo básico da UNIQ

**Entregável:** 4 fundadores ativos na Base UNIQ.

---

## Backlog Pós-MVP

- [ ] Painel administrativo completo da UNIQ
- [ ] Módulo de Agenda (Google Agenda/Outlook)
- [ ] Módulo de Mídias Sociais
- [ ] ERP básico (produtos, serviços, finanças)
- [ ] Site/landing page do parceiro
- [ ] Trilhas de desenvolvimento do empreendedor
- [ ] Relatórios avançados (upsell)
- [ ] Revisar e habilitar RLS em todas as tabelas do Supabase
- [ ] Documentar dívida técnica do schema do protótipo

---

## Como usar este arquivo

1. No início de cada sessão, leia este arquivo para saber o status atual.
2. Ao concluir uma tarefa, marque como `[x]`.
3. Ao encontrar um bloqueio, adicione uma observação na tarefa.
4. Se o escopo mudar, atualize as semanas ou backlog.
