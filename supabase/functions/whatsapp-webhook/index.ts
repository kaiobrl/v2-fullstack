import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  try {
    const payload = await req.json()
    console.log("Webhook received:", payload)

    // Example logic:
    // If payload contains a new lead, call your WhatsApp provider API
    // e.g. Z-API, Evolution API, Twilio, etc.
    
    // const lead = payload.record;
    // await sendWhatsAppMessage(lead.whatsapp, `Olá ${lead.name}, recebemos seu interesse!`);

    return new Response(
      JSON.stringify({ message: "Webhook processado com sucesso" }),
      { headers: { "Content-Type": "application/json" }, status: 200 },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { "Content-Type": "application/json" }, status: 400 },
    )
  }
})
