import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface WebhookPayload {
  instance_id: string
  message: {
    id: string
    from: string
    text: string
    timestamp: string
    type: 'text' | 'image' | 'audio' | 'document' | 'video'
    media_url?: string
  }
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabase = createClient(supabaseUrl, supabaseKey)

    const payload: WebhookPayload = await req.json()
    const { instance_id, message } = payload

    // 1. Buscar configuração da empresa pelo instance_id (NOVA TABELA)
    const { data: config, error: configError } = await supabase
      .from('crm_chat_config')
      .select('*, empresa_id')
      .eq('evolution_instance_id', instance_id)
      .single()

    if (configError || !config) {
      console.error('Config not found for instance:', instance_id)
      return new Response(JSON.stringify({ 
        error: 'Instance not found' 
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 404,
      })
    }

    // 2. Verificar se atendente está ativo
    if (!config.agente_ativo) {
      console.log('Attendant is not active for instance:', instance_id)
      return new Response(JSON.stringify({ 
        success: true, 
        message: 'Attendant is paused' 
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 3. Buscar ou criar conversa (NOVA TABELA)
    const phone = message.from.replace(/\D/g, '')
    let conversationId: string

    const { data: existingConv } = await supabase
      .from('crm_chat_conversas')
      .select('id')
      .eq('empresa_id', config.empresa_id)
      .eq('canal_id', phone)
      .eq('canal', 'whatsapp')
      .eq('status', 'em_andamento')
      .single()

    if (existingConv) {
      conversationId = existingConv.id
    } else {
      // Criar nova conversa
      const { data: newConv, error: convError } = await supabase
        .from('crm_chat_conversas')
        .insert({
          empresa_id: config.empresa_id,
          contato_id: null, // Será associado posteriormente
          canal: 'whatsapp',
          canal_id: phone,
          canal_dados: { pushName: phone },
          status: 'em_andamento',
        })
        .select('id')
        .single()

      if (convError) throw convError
      conversationId = newConv!.id
    }

    // 4. Gravar mensagem recebida (NOVA TABELA)
    const { error: msgError } = await supabase
      .from('crm_chat_mensagens')
      .insert({
        conversa_id: conversationId,
        remetente: 'contato',
        tipo: message.type === 'text' ? 'texto' : message.type,
        conteudo: message.text,
        arquivo_url: message.media_url,
        canal_mensagem_id: message.id,
        status: 'recebida',
      })

    if (msgError) throw msgError

    // 5. Se modo URA ativo, processar regras
    let automatedResponse: string | null = null
    if (config.ura_ativa) {
      // Verificar horário comercial
      const now = new Date()
      const dayNames = ['dom', 'seg', 'ter', 'qua', 'qui', 'sex', 'sab'] as const
      const currentDay = dayNames[now.getDay()]
      const horarioConfig = config.horario_funcionamento
      
      const isBusinessDay = horarioConfig.dias.includes(currentDay)
      const currentTime = now.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', hour12: false })
      const isBusinessHours = isBusinessDay && 
        currentTime >= horarioConfig.inicio &&
        currentTime <= horarioConfig.fim

      if (!isBusinessHours) {
        automatedResponse = config.mensagem_ausencia
      } else {
        // Verificar keywords na URA
        const uraRules = config.ura_config?.opcoes || []
        const lowerText = message.text.toLowerCase()
        
        for (const rule of uraRules) {
          if (rule.label && lowerText.includes(rule.label.toLowerCase())) {
            // Aqui você pode ter respostas específicas por opção
            automatedResponse = `Você escolheu: ${rule.label}. Em breve um atendente entrará em contato.`
            break
          }
        }
      }

      // Se tem resposta automática, enviar
      if (automatedResponse) {
        const { error: autoMsgError } = await supabase
          .from('crm_chat_mensagens')
          .insert({
            conversa_id: conversationId,
            remetente: 'agente',
            tipo: 'texto',
            conteudo: automatedResponse,
            status: 'enviada',
          })

        if (autoMsgError) throw autoMsgError

        // Chamar webhook do n8n para enviar a mensagem de volta
        console.log('Automated response triggered:', {
          instance_id: instance_id,
          phone: phone,
          message: automatedResponse,
        })
      }
    }

    return new Response(JSON.stringify({
      success: true,
      conversation_id: conversationId,
      automated_response: !!automatedResponse,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error) {
    console.error('Webhook error:', error)
    return new Response(JSON.stringify({ 
      error: error.message 
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
