import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
        const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        const supabase = createClient(supabaseUrl, supabaseKey)

        const generatedInsights = []

        // 1. CHURN RISK (Inactive > 45 days)
        const dateLimitChurn = new Date();
        dateLimitChurn.setDate(dateLimitChurn.getDate() - 45);

        const { data: churnCandidates } = await supabase
            .from('crm_leads')
            .select('id, nome, ultima_interacao, empresa_id')
            .lt('ultima_interacao', dateLimitChurn.toISOString())
            .neq('status', 'Churn')
            .limit(5);

        if (churnCandidates) {
            for (const client of churnCandidates) {
                generatedInsights.push({
                    empresa_id: client.empresa_id,
                    type: 'CHURN_RISK',
                    content: `⚠️ O cliente ${client.nome} não interage desde ${new Date(client.ultima_interacao).toLocaleDateString()}. Sugestão: Ofereça um checkup gratuito.`,
                    metadata: { client_id: client.id, scenario: 'churn_45d' }
                });
            }
        }

        // 2. STUCK DEALS (Open > 7 days)
        const dateLimitStuck = new Date();
        dateLimitStuck.setDate(dateLimitStuck.getDate() - 7);

        const { data: stuckDeals } = await supabase
            .from('crm_oportunidades')
            .select('id, titulo, valor, estagio, empresa_id, created_at')
            .lt('created_at', dateLimitStuck.toISOString())
            .not('estagio', 'in', '("Ganho","Perdido","Finalizado")')
            .limit(5);

        if (stuckDeals) {
            for (const deal of stuckDeals) {
                generatedInsights.push({
                    empresa_id: deal.empresa_id,
                    type: 'STUCK_DEAL',
                    content: `⏳ A oportunidade "${deal.titulo}" (R$ ${deal.valor}) está parada há 7 dias. Mande um "Oi, sumido" para reativar.`,
                    metadata: { deal_id: deal.id, scenario: 'stuck_7d' }
                });
            }
        }

        // 3. PERSIST INSIGHTS
        if (generatedInsights.length > 0) {
            const { error: insertError } = await supabase
                .from('advisor_insights')
                .insert(generatedInsights);

            if (insertError) {
                console.error("Error saving insights:", insertError);
                throw insertError;
            }
        }

        return new Response(JSON.stringify({
            success: true,
            insights_generated: generatedInsights.length,
            insights_preview: generatedInsights
        }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });

    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 500,
        });
    }
});
