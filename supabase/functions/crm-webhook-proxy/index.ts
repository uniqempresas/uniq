import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        // 1. Get the payload from the request body
        const { body } = await req.json()

        // 2. Define the n8n Webhook URL (Hidden on server side)
        const N8N_WEBHOOK_URL = 'https://webhook.uniqempresas.com/webhook/1aa66141-beee-41c4-9fb8-409008114416'

        // 3. Forward the request to n8n
        const response = await fetch(N8N_WEBHOOK_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(body),
        })

        // 4. Return success to the client
        // Note: n8n might return 200 "Webhook received" textual response, or JSON.
        // We'll just return a success JSON to our client.
        if (response.ok) {
            // Try to parse JSON if n8n returns it, otherwise text
            const text = await response.text()
            return new Response(JSON.stringify({ success: true, n8n_response: text }), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            })
        } else {
            return new Response(JSON.stringify({ error: 'Failed to send to n8n', status: response.status }), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 502,
            })
        }

    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
        })
    }
})
