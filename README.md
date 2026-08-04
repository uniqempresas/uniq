# Base UNIQ

Plataforma de Transformação Digital para microempresas. Sua central de operações com a Melissa, sua parceira digital.

## Stack

- **Frontend:** Next.js 14 (App Router) + TypeScript
- **Estilização:** Tailwind CSS + shadcn/ui
- **Banco de dados:** Supabase (Postgres + Auth + RLS)
- **Autenticação:** Supabase Auth
- **Hospedagem:** Vercel

## Pré-requisitos

- Node.js 18+
- npm ou yarn
- Conta no Supabase (gratuita)
- Conta na Vercel (gratuita)

## Instalação

```bash
# Clone o repositório
git clone <url-do-repositorio>
cd base-uniq

# Instale as dependências
npm install

# Configure as variáveis de ambiente
cp .env.local.example .env.local
# Edite .env.local com suas credenciais do Supabase

# Execute em desenvolvimento
npm run dev
```

## Variáveis de Ambiente

| Variável | Descrição |
|----------|-----------|
| `NEXT_PUBLIC_SUPABASE_URL` | URL do projeto Supabase |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Chave anônima do Supabase |
| `SUPABASE_SERVICE_ROLE_KEY` | Chave de serviço do Supabase (apenas server-side) |

## Scripts

```bash
npm run dev      # Desenvolvimento
npm run build    # Build de produção
npm run start    # Iniciar produção
npm run lint     # Verificar lint
```

## Estrutura

```
src/
├── app/              # Rotas do Next.js App Router
│   ├── (auth)/       # Páginas de autenticação
│   ├── dashboard/    # Dashboard do parceiro
│   └── chat/         # Chat com a Melissa
├── components/
│   └── ui/           # Componentes shadcn/ui
├── lib/
│   ├── supabase/     # Clientes Supabase
│   └── utils.ts      # Utilitários
├── hooks/            # Custom hooks
└── types/            # Tipagens TypeScript
supabase/
└── migrations/       # Migrations do banco
```

## Deploy

O deploy é feito na Vercel. Conecte o repositório do GitHub e configure as variáveis de ambiente no painel da Vercel.
