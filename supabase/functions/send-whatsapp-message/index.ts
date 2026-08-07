import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface SendMessagePayload {
  conversation_id: string
  content: string
  sender_id: string
  message_type?: 'texto' | 'imagem' | 'audio' | 'documento'
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabase = createClient(supabaseUrl, supabaseKey)

    const payload: SendMessagePayload = await req.json()
    const { conversation_id, content, sender_id, message_type = 'texto' } = payload

    // 1. Buscar conversa e configuração (NOVAS TABELAS)
    const { data: conversation, error: convError } = await supabase
      .from('crm_chat_conversas')
      .select(`
        *,
        crm_chat_config!inner(*)
      `)
      .eq('id', conversation_id)
      .single()

    if (convError || !conversation) {
      return new Response(JSON.stringify({ 
        error: 'Conversation not found' 
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 404,
      })
    }

    // 2. Gravar mensagem no banco (NOVA TABELA)
    const { data: message, error: msgError } = await supabase
      .from('crm_chat_mensagens')
      .insert({
        conversa_id: conversation_id,
        remetente: 'usuario',
        usuario_id: sender_id,
        tipo: message_type,
        conteudo: content,
        status: 'enviando',
      })
      .select()
      .single()

    if (msgError) throw msgError

    // 3. Atualizar conversa com última mensagem
    await supabase
      .from('crm_chat_conversas')
      .update({
        updated_at: new Date().toISOString(),
        ultima_mensagem: content.substring(0, 100),
      })
      .eq('id', conversation_id)

    // 4. Enviar webhook para n8n (se configurado)
    const config = conversation.crm_chat_config
    if (config?.evolution_instance_id && conversation.canal === 'whatsapp') {
      // Aqui você integra com o n8n para enviar a mensagem real pelo WhatsApp
      console.log('Message sent to n8n:', {
        instance_id: config.evolution_instance_id,
        phone: conversation.canal_id,
        message: content,
        message_id: message.id,
      })

      // Exemplo de como seria a chamada ao n8n:
      // await fetch('https://n8n.seudominio.com/webhook/send-whatsapp', {
      //   method: 'POST',
      //   headers: { 'Content-Type': 'application/json' },
      //   body: JSON.stringify({
      //     instance_id: config.evolution_instance_id,
      //     phone: conversation.canal_id,
      //     message: content,
      //   }),
      // })
    }

    // 5. Atualizar status para enviada
    await supabase
      .from('crm_chat_mensagens')
      .update({ status: 'enviada' })
      .eq('id', message.id)

    return new Response(JSON.stringify({
      success: true,
      message: message,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error) {
    console.error('Send message error:', error)
    return new Response(JSON.stringify({ 
      error: error.message 
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
