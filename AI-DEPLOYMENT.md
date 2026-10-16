# SkillBox AI Studio — deployment checklist

The public static site cannot safely call an AI provider directly: API keys must stay server-side.

1. Create a **separate** Supabase project for SkillBox AI (do not use FlipRadar).
2. Deploy `supabase/functions/generate/index.ts` as the `generate` Edge Function.
3. Configure server-side `OPENAI_API_KEY`, optionally `OPENAI_MODEL`.
4. **Before** enabling `SKILLBOX_AI_ENABLED=true`, implement authentication, per-user quotas, rate limiting, cost ceilings, abuse monitoring, and (for paid access) verified payment entitlements. The sample function intentionally defaults to disabled.
5. Create `ai-config.json` in the website root with `{"endpoint":"https://YOUR_PROJECT.supabase.co/functions/v1/generate"}`. This is a public URL, **not** a secret.
6. Test CORS, errors, input length, concurrency, and provider costs. Never commit API keys.

AI generation is **not live** until these steps are completed. This repository contains only the UI and a backend starter, not an operational paid AI service.
