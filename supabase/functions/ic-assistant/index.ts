import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!

Deno.serve(async (req) => {
try {
const { question } = await req.json()
const authHeader = req.headers.get("Authorization")!

// Uses the caller's own auth token, so RLS scopes every query to
// their own home — the AI never sees another user's data.
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
global: { headers: { Authorization: authHeader } },
})

const { data: homes } = await supabase.from("homes").select("*")
const home = homes?.[0]

let context = "No home or resources on record yet."
if (home) {
const { data: assets } = await supabase
.from("home_assets")
.select("*")
.eq("home_id", home.id)
const { data: tasks } = await supabase
.from("maintenance_tasks")
.select("*, home_assets!inner(home_id, category)")
.eq("home_assets.home_id", home.id)

context = `Resources on record:\n${JSON.stringify(assets, null, 2)}\n\nOpen maintenance tasks:\n${JSON.stringify(tasks, null, 2)}`
}

const systemPrompt = `You are the IC Assistant inside IC: Home, a home-management app styled after incident command systems. Answer using ONLY the resource data below. Be concise and use plain language. If the data doesn't answer the question, say so.\n\n${context}`

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
system: systemPrompt,
messages: [{ role: "user", content: question }],
}),
})

if (!anthropicRes.ok) {
return new Response(JSON.stringify({ answer: "The IC Assistant hit an error reaching its AI provider." }), {
headers: { "Content-Type": "application/json" },
})
}

const anthropicData = await anthropicRes.json()
const answer = anthropicData.content?.[0]?.text ?? "No response."

return new Response(JSON.stringify({ answer }), {
headers: { "Content-Type": "application/json" },
})
} catch (e) {
return new Response(JSON.stringify({ answer: "Something went wrong processing that question." }), {
headers: { "Content-Type": "application/json" },
})
}
})
