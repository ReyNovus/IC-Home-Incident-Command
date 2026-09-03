import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!

Deno.serve(async (req) => {
try {
const { image } = await req.json()

const prompt = `Look at this photo of a home equipment nameplate/label. Extract:
- category: one of hvac, water_heater, pool, roof, appliance, vehicle, electrical, plumbing, other
- manufacturer
- model_number
- serial_number

Respond with ONLY a JSON object with those four keys. Use null for any field you cannot read clearly. Do not guess at serial numbers — only include one if you can actually read it on the label.`

const anthropicRes = await fetch("https://api.anthropic.com/v1/messages", {
method: "POST",
headers: {
"content-type": "application/json",
"x-api-key": ANTHROPIC_API_KEY,
"anthropic-version": "2023-06-01",
},
body: JSON.stringify({
model: "claude-sonnet-4-5",
max_tokens: 300,
messages: [
{
role: "user",
content: [
{ type: "image", source: { type: "base64", media_type: "image/jpeg", data: image } },
{ type: "text", text: prompt },
],
},
],
}),
})

const anthropicData = await anthropicRes.json()
const text = anthropicData.content?.[0]?.text ?? "{}"
const cleaned = text.replace(/```json|```/g, "").trim()
const parsed = JSON.parse(cleaned)

return new Response(JSON.stringify(parsed), {
headers: { "Content-Type": "application/json" },
})
} catch (e) {
return new Response(JSON.stringify({ error: "Could not process image" }), {
status: 500,
headers: { "Content-Type": "application/json" },
})
}
})
