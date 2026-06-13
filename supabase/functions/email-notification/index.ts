import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  try {
    const payload = await req.json()
    console.log("Email Webhook received:", payload)

    // Example logic:
    // If payload contains a new lead, send an email to the admin using Resend / SendGrid / Supabase Email
    
    // const lead = payload.record;
    // await sendEmail('admin@oferta.com', 'Novo Lead Cadastrado', `Nome: ${lead.name}, WhatsApp: ${lead.whatsapp}`);

    return new Response(
      JSON.stringify({ message: "Notificação de email processada" }),
      { headers: { "Content-Type": "application/json" }, status: 200 },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { "Content-Type": "application/json" }, status: 400 },
    )
  }
})
