# AGENTS.md — Base UNIQ

> Instruções para agentes de IA trabalharem no projeto Base UNIQ.

## Stack

- **Framework:** Next.js 14 (App Router)
- **Linguagem:** TypeScript
- **Estilização:** Tailwind CSS
- **Componentes:** shadcn/ui
- **Banco de dados:** Supabase (Postgres + Auth + RLS)
- **Autenticação:** Supabase Auth
- **Hospedagem:** Vercel
- **IA/Agente:** n8n + OpenRouter
- **WhatsApp/Instagram:** Evolution API

## Documentos de referência obrigatórios

Leia sempre que aplicável:

- `CONTEXTO_UNIQ.md` — contexto estratégico, persona, regras de negócio, definição da Melissa
- `DESIGN.md` — design system, cores, tipografia, componentes, regras visuais
- `tracking/tracking.md` — status e próximos passos do desenvolvimento
- `AGENTS.md` — este arquivo

## Regras gerais

1. Sempre consulte `tracking/tracking.md` no início de cada sessão para saber o status atual.
2. Siga o `DESIGN.md` para qualquer interface gerada.
3. Respeite a arquitetura: Next.js frontend + Supabase backend.
4. Use TypeScript. Evite `any`.
5. Componentes visuais devem usar `shadcn/ui` quando possível.
6. Nunca exponha secrets, tokens ou credenciais no código.
7. Mantenha a UI em português (Brasil).
8. Não use jargão técnico visível para o parceiro (ex: webhook, API, token).
9. Sempre verifique se a alteração precisa ser refletida em `tracking/tracking.md`.

## Comandos comuns

```bash
# instalar dependências
npm install

# rodar em desenvolvimento
npm run dev

# build de produção
npm run build

# lint
npm run lint
```

## Estrutura de pastas sugerida

```
UNIQ/
├── src/
│   ├── app/              # rotas do Next.js App Router
│   ├── components/       # componentes React
│   ├── lib/              # utilitários, clientes (supabase), helpers
│   ├── hooks/            # custom hooks
│   └── types/            # tipagens TypeScript
├── supabase/
│   └── migrations/       # migrations do banco
├── docs/
│   └── design/           # ativos visuais (logo, avatar, paleta)
├── public/               # assets estáticos
├── CONTEXTO_UNIQ.md
├── DESIGN.md
├── AGENTS.md
└── tracking/
    └── tracking.md
```

## Integrações

- **n8n:** endpoints em `src/app/api/` para receber e enviar dados
- **Supabase:** cliente em `src/lib/supabase/`
- **Evolution API:** integração via n8n, não diretamente no Next.js

## Multi-tenant

Cada query do Supabase deve respeitar o `parceiro_id` do usuário logado. Use Row Level Security (RLS) para garantir isolamento de dados entre parceiros.

## Estilo e qualidade

- Prefira componentes pequenos e reutilizáveis.
- Evite lógica de negócio complexa diretamente em páginas do Next.js.
- Adicione comentários apenas quando necessário para explicar decisões não óbvias.
- Mantenha consistência com o `DESIGN.md` em cores, espaçamento e tipografia.

## Notas sobre a Melissa

- A Melissa é a interface humana da UNIQ. Sua voz é próxima, direta, capaz e motivadora.
- O avatar da Melissa deve estar presente em todo ponto de conversa.
- A Melissa não toma decisões, não compartilha dados entre parceiros e não fecha negócios sozinha.
