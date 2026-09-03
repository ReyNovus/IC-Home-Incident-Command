import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!

Deno.serve(async (req) => {
try {
const { assetId } = await req.json()
const authHeader = req.headers.get("Authorization")!

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
global: { headers: { Authorization: authHeader } },
})

const { data: asset, error: assetError } = await supabase
.from("home_assets")
.select("*")
.eq("id", assetId)
.single()
if (assetError || !asset) {
return new Response(JSON.stringify({ error: "Resource not found" }), {
status: 404,
headers: { "Content-Type": "application/json" },
})
}

const { data: existingTasks } = await supabase
.from("maintenance_tasks")
.select("title, status")
.eq("asset_id", assetId)

const today = new Date().toISOString().slice(0, 10)

const prompt = `A homeowner has this piece of equipment on record:
Category: ${asset.category}
Manufacturer: ${asset.manufacturer ?? "unknown"}
Model: ${asset.model_number ?? "unknown"}
Installed: ${asset.install_date ?? "unknown"}
Today's date: ${today}

Existing tasks already logged for it: ${JSON.stringify(existingTasks ?? [])}

Suggest 2-4 realistic, specific maintenance tasks for this type of equipment (e.g. filter changes, inspections, servicing intervals typical for this category). Don't repeat tasks that are already logged. Give each a reasonable due_date (YYYY-MM-DD) based on typical maintenance intervals for this equipment type, using today's date as the starting point.

Respond with ONLY a JSON array, no other text, in this exact shape:
[{"title": "...", "due_date": "YYYY-MM-DD", "description": "..."}]`

const anthropicRes = await fetch("https://api.anthropic.com/v1/messages", {
method: "POST",
headers: {
"content-type": "application/json",
"x-api-key": ANTHROPIC_API_KEY,
"anthropic-version": "2023-06-01",
},
body: JSON.stringify({
model: "claude-sonnet-4-5",
max_tokens: 500,
messages: [{ role: "user", content: prompt }],
}),
})

const anthropicData = await anthropicRes.json()
const text = anthropicData.content?.[0]?.text ?? "[]"
const cleaned = text.replace(/```json|```/g, "").trim()
const suggestions = JSON.parse(cleaned)

return new Response(JSON.stringify({ suggestions }), {
headers: { "Content-Type": "application/json" },
})
} catch (e) {
return new Response(JSON.stringify({ error: "Could not generate suggestions" }), {
status: 500,
headers: { "Content-Type": "application/json" },
})
}
})
