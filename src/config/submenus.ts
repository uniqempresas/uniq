
export interface SubMenuConfig {
    title: string;
    subtitle: string;
    items: MenuItem[];
}

export interface MenuItem {
    icon?: string;
    label?: string;
    active?: boolean;
    href?: string;
    type?: 'divider';
    badge?: string;
    children?: MenuItem[];
    id?: string;
    view?: string; // Target view
    disabled?: boolean;
    target?: string; // '_blank' para abrir em nova aba
}

export const MENU_CONFIG: Record<string, SubMenuConfig> = {
    dashboard: {
        title: 'Minha Empresa',
        subtitle: 'Visão Geral',
        items: [
            { icon: 'grid_view', label: 'Dashboard Hub', active: true, view: 'home', href: '#' },
            { type: 'divider' },
            { icon: 'point_of_sale', label: 'Vendas & PDV', href: '/sales' },
            {
                id: 'cadastros',
                icon: 'app_registration',
                label: 'Cadastros',
                href: '#',
                children: [
                    { label: 'Produtos', icon: 'package_2', view: 'products' },
                    { label: 'Serviços', icon: 'handyman', view: 'services' },
                    { label: 'Clientes', icon: 'group', view: 'clients' },
                    { label: 'Fornecedores', icon: 'warehouse', view: 'suppliers' },
                    { label: 'Colaboradores', icon: 'badge', view: 'collaborators' }
                ]
            },

        ],
    },
    storefront: {
        title: 'Loja Virtual',
        subtitle: 'Gestão de E-commerce',
        items: [
            { icon: 'visibility', label: 'Ver Loja', view: 'preview', href: '/c/:slug', target: '_blank' },
            { icon: 'palette', label: 'Aparência', view: 'appearance', href: '#' },
            { icon: 'view_carousel', label: 'Banners & Hero', view: 'banners', href: '#' },
            { type: 'divider' },
            { icon: 'category', label: 'Categorias (Menu)', view: 'categories', href: '#', disabled: true },
            { icon: 'local_shipping', label: 'Entregas/Frete', view: 'shipping', href: '#' },
        ],
    },
    inventory: {
        title: 'Estoque',
        subtitle: 'Gestão de Produtos',
        items: [
            { icon: 'inventory', label: 'Produtos', active: true, href: '#' },
            { icon: 'category', label: 'Categorias', href: '#' },
            { icon: 'swap_vert', label: 'Movimentações', href: '#' },
            { icon: 'warehouse', label: 'Fornecedores', href: '#' },
        ],
    },
    team: {
        title: 'Equipe',
        subtitle: 'Gestão de Pessoas',
        items: [
            { icon: 'group', label: 'Colaboradores', active: true, href: '#' },
            { icon: 'badge', label: 'Cargos', href: '#' },
            { icon: 'work_history', label: 'Ponto Eletrônico', href: '#' },
        ],
    },
    reports: {
        title: 'Relatórios',
        subtitle: 'Inteligência',
        items: [
            { icon: 'bar_chart', label: 'Vendas', active: true, href: '#' },
            { icon: 'pie_chart', label: 'Financeiro', href: '#' },
            { icon: 'trending_up', label: 'Metas', href: '#' },
        ],
    },
    settings: {
        title: 'Configurações',
        subtitle: 'Sistema',
        items: [
            { icon: 'settings', label: 'Geral', active: true, href: '#' },
            { icon: 'domain', label: 'Empresa', href: '#' },
            { icon: 'lock', label: 'Segurança', href: '#' },
            { icon: 'credit_card', label: 'Faturamento', href: '#' },
        ],
    },
    store: {
        title: 'Loja',
        subtitle: 'Módulos & Adds',
        items: [
            { icon: 'storefront', label: 'Módulo Store', active: true, href: '#' },
            { icon: 'extension', label: 'Integrações', href: '#' },
        ],
    },
    modules: {
        title: 'Loja',
        subtitle: 'Módulos & Adds',
        items: [
            { icon: 'check_circle', label: 'Módulos Escolhidos', active: true, href: '/modules' },
            { icon: 'add_shopping_cart', label: 'Novos Módulos', href: '/modules/new' },
            { icon: 'construction', label: 'Em Desenvolvimento', href: '/modules/dev' },
            { type: 'divider' },
            { icon: 'arrow_back', label: 'Voltar ao Dashboard', href: '/dashboard' },
        ],
    },

}
