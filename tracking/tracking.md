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
| Setup do projeto Next.js | 🟡 Em progresso | Semana 1 — projeto local pronto, build e lint OK |
| Autenticação com Supabase | 🟡 Em progresso | Semana 1 — tela de login criada, falta integrar com Supabase Auth e rodar migrations |
| Dashboard inicial + Sidebar | ⬜ Pendente | Semana 2 |
| Chat com Melissa (Base UNIQ) | ⬜ Pendente | Semana 2 |
| Integração n8n ↔ Base UNIQ | ⬜ Pendente | Semana 3 |
| CRM leve de leads | ⬜ Pendente | Semana 3 |
| Visualizador de conversas WhatsApp | ⬜ Pendente | Semana 4 |
| Responder pelo Base UNIQ | ⬜ Pendente | Semana 4 |
| Testes com 1 fundador | ⬜ Pendente | Semana 5 |
| Ajustes + expansão 4 fundadores | ⬜ Pendente | Semana 6 |

---

## Semana 1 — Setup e Fundação

**Objetivo:** Ter o projeto rodando na Vercel com login funcional.

### Tarefas
- [ ] Criar repositório no GitHub *(próximo passo externo)*
- [x] Inicializar projeto Next.js 14 com App Router
- [x] Configurar Tailwind CSS com cores do `DESIGN.md`
- [x] Instalar e configurar `shadcn/ui`
- [x] Configurar conexão com Supabase (`@supabase/ssr`) — clientes e middleware prontos, aguardando credenciais
- [x] Criar schema inicial no Supabase — migration `001_initial_schema.sql` pronta, aguardando execução no Supabase
- [ ] Implementar autenticação (login/cadastro) com Supabase Auth — tela criada com stub, falta integração real
- [ ] Deploy inicial na Vercel *(próximo passo externo)*
- [ ] Testar login em produção *(próximo passo externo)*

**Entregável:** URL pública com tela de login funcional.

---

## Semana 2 — Dashboard e Chat da Melissa

**Objetivo:** O parceiro loga e vê a Melissa na Base UNIQ.

### Tarefas
- [ ] Criar layout padrão (sidebar escura + conteúdo claro)
- [ ] Aplicar identidade UNIQ (cores, tipografia, avatar)
- [ ] Criar dashboard inicial do parceiro
- [ ] Criar tela de chat com a Melissa (modo consultoria)
- [ ] Exibir avatar da Melissa nas mensagens
- [ ] Salvar mensagens do chat no Supabase
- [ ] Criar painel de módulos ativos/pendentes

**Entregável:** Parceiro consegue logar, conversar com a Melissa e ver módulos.

---

## Semana 3 — Integração com n8n e CRM

**Objetivo:** A Base UNIQ conversa com o fluxo do n8n.

### Tarefas
- [ ] Criar webhooks no Next.js para receber dados do n8n
- [ ] Ajustar fluxo `CONSULTORIA_MEL uat4` para enviar mensagens para a Base UNIQ
- [ ] Criar endpoint para o n8n consultar dados do parceiro
- [ ] Criar tela de CRM leve (lista de leads)
- [ ] Criar tela de detalhes do lead
- [ ] Sincronizar leads entre Supabase e n8n

**Entregável:** Mensagens e leads fluem entre n8n e Base UNIQ.

---

## Semana 4 — Conversas do WhatsApp

**Objetivo:** O parceiro vê e pode intervir nas conversas da Melissa no WhatsApp.

### Tarefas
- [ ] Criar tela de visualização de conversas do WhatsApp
- [ ] Exibir histórico de mensagens por lead/cliente
- [ ] Permitir que o parceiro responda pela Base UNIQ
- [ ] Enviar resposta do parceiro de volta para o WhatsApp via n8n
- [ ] Marcar conversas como atribuídas ao parceiro ou à Melissa
- [ ] Notificações de novas mensagens

**Entregável:** Funcionalidade estilo Chatwoot dentro da Base UNIQ.

---

## Semana 5 — Teste com 1 Fundador

**Objetivo:** Validar com uso real antes de escalar.

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

**Objetivo:** Preparar para os 4 fundadores.

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

---

## Como usar este arquivo

1. No início de cada sessão, leia este arquivo para saber o status atual.
2. Ao concluir uma tarefa, marque como `[x]`.
3. Ao encontrar um bloqueio, adicione uma observação na tarefa.
4. Se o escopo mudar, atualize as semanas ou backlog.
