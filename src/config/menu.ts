export interface SubMenuItem {
    id: string
    icon: string
    label: string
    view: string
}

export interface MenuItem {
    id: string
    icon: string
    label: string
    route?: string
    moduleCode?: string
    submenu?: SubMenuItem[]
}

export const MAIN_NAV_ITEMS: MenuItem[] = [
    {
        id: 'dashboard',
        icon: 'fingerprint',
        label: 'Minha Empresa',
        route: '/dashboard',
        submenu: [
            { id: 'products', icon: 'package_2', label: 'Produtos', view: 'products' },
            { id: 'services', icon: 'handyman', label: 'Serviços', view: 'services' },
            { id: 'clients', icon: 'group', label: 'Clientes', view: 'clients' },
            { id: 'suppliers', icon: 'warehouse', label: 'Fornecedores', view: 'suppliers' },
            { id: 'collaborators', icon: 'badge', label: 'Colaboradores', view: 'collaborators' }
        ]
    },
    {
        id: 'sales',
        icon: 'point_of_sale',
        label: 'Vendas & PDV',
        route: '/sales'
    },
    {
        id: 'attendant',
        icon: 'support_agent',
        label: 'Atendente',
        route: '/attendant',
        moduleCode: 'attendant'
    },
    {
        id: 'crm',
        icon: 'groups',
        label: 'CRM',
        route: '/crm',
        moduleCode: 'crm'
    },
    {
        id: 'storefront',
        icon: 'storefront',
        label: 'Loja Virtual',
        route: '/dashboard/store-config',
        moduleCode: 'storefront'
    },
    {
        id: 'finance',
        icon: 'attach_money',
        label: 'Financeiro',
        route: '/finance',
        moduleCode: 'finance'
    },
    {
        id: 'inventory',
        icon: 'inventory_2',
        label: 'Estoque',
        moduleCode: 'inventory'
    },
    {
        id: 'team',
        icon: 'group',
        label: 'Equipe',
        moduleCode: 'team'
    },
    {
        id: 'reports',
        icon: 'bar_chart',
        label: 'Relatórios',
        moduleCode: 'reports'
    },
]
