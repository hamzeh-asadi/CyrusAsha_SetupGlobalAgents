---
name: pre-launch-security-checklist
description: "Comprehensive pre-launch production security verification for web, SaaS, and AI applications. Audits database RLS, secrets, auth/RBAC, API rate limiting, AI prompt/tool defense, and security headers before going live."
sources:
  - "AI QA Monkey: Pre-Launch Security Checklist: What to Verify Before Going Live (https://aiqamonkey.com/blog/pre-launch-security-checklist.php)"
  - "Kalit AI: Pre-Launch Security Checklist for Founders (https://kalit.ai/blog/pre-launch-security-checklist-for-founders)"
  - "Vibe-Eval: Founder Pre-Launch Security Checklist for AI Apps (2026) (https://vibe-eval.com/guides/solo-founder-prelaunch-security-checklist/)"
  - "300 Claude Skills & Prompts Collection (https://app.notion.com/p/300-Claude-Skills-Prompts-c357bda2535782d0b81501d86697adf4)"
---

# Pre-Launch Security Checklist for Production AI & SaaS Applications

This playbook provides a comprehensive, multi-layer security audit that founders and engineering teams must execute before launching any web application, API, or AI-powered service into production.

---

## 1. Secrets & Environment Hygiene
- [ ] **Git Repository Scan**: Run secret scanning tools (e.g., `gitleaks detect --source . -v` or `trufflehog git file://.`) to verify no API tokens, database connection strings, or private keys exist in commit history.
- [ ] **.gitignore Validation**: Ensure `.env`, `.env.local`, `.env.production`, `*.pem`, `*.key`, `id_rsa`, and local sqlite/log files are strictly ignored.
- [ ] **Environment Separation**: Distinct production keys vs development/staging keys for Stripe, OpenAI, Anthropic, AWS, Resend, and Supabase.
- [ ] **Secrets Manager**: Store production secrets in a dedicated secret store (AWS Secrets Manager, Cloudflare Secrets, Vercel Env, Doppler) rather than hardcoded environment strings.

---

## 2. Database & Storage Architecture
- [ ] **Row-Level Security (RLS)**: If using Supabase, PostgreSQL RLS, or Firebase, verify RLS is explicitly enabled on **every** public schema table (`ALTER TABLE <table> ENABLE ROW LEVEL SECURITY;`).
- [ ] **RLS Bypass Audit**: Ensure service role keys (`SUPABASE_SERVICE_ROLE_KEY`) are never exposed to client-side code, Next.js public envs (`NEXT_PUBLIC_*`), or Vite client bundles (`VITE_*`).
- [ ] **Storage Bucket Access**: Cloud storage buckets (S3, Cloudflare R2, Supabase Storage) must have public read/write disabled unless explicitly configured for public static assets. Ensure avatar and document upload folders enforce user-id scoping.
- [ ] **Database Connection Security**: Enforce `sslmode=require` or `sslmode=verify-full` on all production connection strings. Do not expose database ports (`5432`, `3306`, `27017`) directly to `0.0.0.0/0`.

---

## 3. Server-Side Authentication & Authorization
- [ ] **Horizontal & Vertical Privilege Verification (IDOR)**: Verify that users cannot read, modify, or delete resources belonging to other tenants/users by altering path IDs (`/api/projects/123 -> /api/projects/124`). Every query must enforce `WHERE user_id = current_user_id AND org_id = current_org_id`.
- [ ] **Session & Cookie Security**: Cookies must use `HttpOnly`, `Secure`, and `SameSite=Lax` (or `Strict`).
- [ ] **Token Expiration & Refresh**: Access tokens must have short TTLs (15–60 min); refresh tokens must support rotation and revocation upon password change or logout.
- [ ] **Password & MFA Policy**: Enforce strong password hashing (Argon2id or bcrypt with high work factor). Enforce multi-factor authentication for administrative accounts.

---

## 4. API, Webhooks & Rate Limiting
- [ ] **Rate Limiting**: Enforce global and per-route rate limits (e.g., via Upstash Redis or Cloudflare WAF) on:
  - Authentication routes (`/api/auth/*`, `/login`, `/signup`, `/reset-password`)
  - AI model execution endpoints
  - Email sending and SMS OTP endpoints
  - Payment and checkout creation endpoints
- [ ] **Webhook Signature Verification**: Verify HMAC SHA256 signatures on all incoming webhooks (Stripe `stripe.webhooks.constructEvent`, LemonSqueezy, Paddle, GitHub, Clerk).
- [ ] **Idempotent Webhook Processing**: Store webhook `event_id` in a database ledger to prevent duplicate processing on retries.
- [ ] **CORS Configuration**: Configure `Access-Control-Allow-Origin` to explicit trusted domains; never use wildcard `*` with `Allow-Credentials: true`.

---

## 5. AI Application-Specific Security (2026 Guardrails)
- [ ] **Direct & Indirect Prompt Injection Defense**:
  - Delimit untrusted user inputs with unambiguous XML/Markdown tags (`<user_input>...</user_input>`).
  - Instruct models never to interpret contents inside delimiters as system commands.
- [ ] **Token Caps & Cost Protection**: Hard cap `max_tokens` on every completion call. Set request timeouts (e.g., 20–30s) and daily per-user spending/credit limits to prevent denial-of-wallet.
- [ ] **System Prompt Confidentiality**: Never embed private secrets, DB credentials, or sensitive business logic inside system prompts.
- [ ] **Tool Call & MCP Boundaries**: Validate all arguments passed to LLM tool calls against strict JSON schemas. Restrict filesystem access and disallow shell commands without explicit human verification.
- [ ] **Output Sanitization**: Sanitize LLM-generated Markdown/HTML before rendering in the DOM (DOMPurify, react-markdown with strict html sanitization) to prevent stored XSS via generated markdown.

---

## 6. HTTP Security Headers & Production Hardening
- [ ] **Content-Security-Policy (CSP)**: `default-src 'self'; script-src 'self' 'nonce-...'; object-src 'none'; frame-ancestors 'none';`
- [ ] **HSTS**: `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
- [ ] **X-Content-Type-Options**: `nosniff`
- [ ] **X-Frame-Options**: `DENY` or `SAMEORIGIN` (prevents clickjacking)
- [ ] **Referrer-Policy**: `strict-origin-when-cross-origin`
- [ ] **Permissions-Policy**: Restrict camera, microphone, and geolocation access if unused.
- [ ] **Error Handling & Information Disclosure**: Disable detailed stack traces, framework signatures (`X-Powered-By`), and debug consoles in production. Return generic error messages to clients while logging stack traces to Sentry or Datadog.

---

## 7. Supply Chain & Dependencies
- [ ] **Automated Dependency Audit**: Run `npm audit`, `pip-audit`, or `cargo audit` in CI/CD and verify zero critical/high CVEs.
- [ ] **Lockfile Enforcement**: Always commit `package-lock.json`, `pnpm-lock.yaml`, or `poetry.lock` and build in CI with `--frozen-lockfile` or `--immutable`.

---

## Pre-Launch Verification Command
Run the pre-launch security command before production release:
```bash
/CyrusAsha_PreLaunch-Security
# or alias:
/prelaunch-security
```
