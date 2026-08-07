export const formatCurrency = (value: number | string): string => {
    const numberValue = Number(value)
    if (isNaN(numberValue)) return 'R$ 0,00'

    return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
    }).format(numberValue)
}

export const formatCpfCnpj = (value: string): string => {
    const numbers = value.replace(/\D/g, '').slice(0, 14) // Limit to 14 digits

    if (numbers.length > 11) {
        // CNPJ Mask: 00.000.000/0000-00
        return numbers
            .replace(/^(\d{2})(\d)/, '$1.$2')
            .replace(/^(\d{2})\.(\d{3})(\d)/, '$1.$2.$3')
            .replace(/\.(\d{3})(\d)/, '.$1/$2')
            .replace(/(\d{4})(\d)/, '$1-$2')
    } else {
        // CPF Mask: 000.000.000-00
        return numbers
            .replace(/^(\d{3})(\d)/, '$1.$2')
            .replace(/^(\d{3})\.(\d{3})(\d)/, '$1.$2.$3')
            .replace(/\.(\d{3})(\d)/, '.$1-$2')
    }
}

export const formatCpf = (value: string): string => {
    const numbers = value.replace(/\D/g, '').slice(0, 11) // Limit to 11 digits
    return numbers
        .replace(/(\d{3})(\d)/, '$1.$2')
        .replace(/(\d{3})(\d)/, '$1.$2')
        .replace(/(\d{3})(\d{1,2})/, '$1-$2')
        .replace(/(-\d{2})\d+?$/, '$1') // Prevent extra chars
}

export const formatPhone = (value: string): string => {
    const numbers = value.replace(/\D/g, '').slice(0, 11) // Limit to 11 digits

    if (numbers.length > 10) {
        // Mobile: (00) 00000-0000
        return numbers
            .replace(/^(\d{2})(\d)/, '($1) $2')
            .replace(/(\d{5})(\d)/, '$1-$2')
    } else {
        // Landline: (00) 0000-0000
        return numbers
            .replace(/^(\d{2})(\d)/, '($1) $2')
            .replace(/(\d{4})(\d)/, '$1-$2')
    }
}

export const formatCep = (value: string): string => {
    return value
        .replace(/\D/g, '')
        .replace(/^(\d{5})(\d)/, '$1-$2')
        .substr(0, 9)
}
