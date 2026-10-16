// Starter endpoint for a dedicated SkillBox AI Supabase project.
// This is deliberately disabled until authentication, quotas and billing controls exist.
Deno.serve(async (request) => {
  const headers = {
    "Access-Control-Allow-Origin": "https://mazdareket-cpu.github.io",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "content-type",
    "Content-Type": "application/json",
  };
  if (request.method === "OPTIONS") return new Response(null, { status: 204, headers });
  if (request.method !== "POST") return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405, headers });
  return new Response(JSON.stringify({ error: "AI server is not activated yet" }), { status: 503, headers });
});
