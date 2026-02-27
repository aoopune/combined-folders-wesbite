# Supabase Google Auth – standalone test

Minimal app to test **Supabase + Google OAuth** on your machine. No build step; just config and a local server.

**Want to see user data in a table?** Run `supabase-table-setup.sql` in the Supabase SQL Editor once (see step below). Then when you sign in with Google, your email and name are saved to the `auth_users` table so you can see them in **Table Editor**.

---

## 1. Supabase project

1. Go to [supabase.com](https://supabase.com) and sign in.
2. Create a project (or use an existing one).
3. In the dashboard: **Project Settings → API**. Copy:
   - **Project URL** (e.g. `https://xxxx.supabase.co`)
   - **anon public** key

---

## 2. Enable Google in Supabase

1. In the dashboard: **Authentication → Providers**.
2. Open **Google** and turn it **Enabled**.
3. Leave the provider page open; you’ll paste the Google Client ID and Secret here after the next step.

---

## 3. Google OAuth credentials

1. Open [Google Cloud Console](https://console.cloud.google.com/) and select (or create) a project.
2. Go to **APIs & Services → Credentials**.
3. **Create credentials → OAuth client ID**.
4. Application type: **Web application**.
5. **Authorized JavaScript origins** (add both for local test):
   - `http://localhost:3000`
   - `http://127.0.0.1:3000`
6. **Authorized redirect URIs** (use your real Supabase URL):
   - `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`  
   Replace `YOUR_PROJECT_REF` with the ref from your Supabase Project URL (e.g. `abcdefgh` from `https://abcdefgh.supabase.co`).
7. Create and copy the **Client ID** and **Client secret**.
8. In Supabase **Authentication → Providers → Google**, paste the **Client ID** and **Client secret** and save.

---

## 4. (Optional) Table to see user data in Table Editor

1. In Supabase: **SQL Editor** → **New query**.
2. Copy the contents of **`supabase-table-setup.sql`** from this folder, paste into the editor, and **Run**.
3. This creates table `public.auth_users` and RLS so the app can save the signed-in user’s email/name. After you sign in with Google, you’ll see a row in **Table Editor** → **auth_users**.

## 5. Supabase redirect URLs

1. In Supabase: **Authentication → URL Configuration**.
2. **Site URL**: `http://localhost:3000`
3. **Redirect URLs**: add `http://localhost:3000` and `http://localhost:3000/**` (or `http://127.0.0.1:3000` if you use that). Save.

---

## 6. Local config

1. In this folder, copy the example config and edit it:
   ```bash
   copy config.example.js config.js
   ```
2. Open `config.js` and set:
   - `SUPABASE_URL` = your Supabase Project URL
   - `SUPABASE_ANON_KEY` = your anon public key

---

## 7. Run and test

From this folder:

```bash
npx serve -l 3000
```

Then open **http://localhost:3000** in your browser.

- Click **Sign in with Google**.
- Complete the Google sign-in; you should be redirected back and see your email/name and user ID.
- Use **Sign out** to clear the session and try again.

If something fails, check the browser console (F12) and the status message on the page. Common issues:

- **Redirect URL mismatch**: Site URL and Redirect URLs in Supabase must match exactly what you use (e.g. `http://localhost:3000`).
- **Google redirect URI**: Must be `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback` with the correct project ref.
- **Config**: `config.js` must exist and contain valid `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

---

## Test Supabase + Razorpay together

Use **`test-both.html`** to test auth and payments on one page. Successful Razorpay payments are saved to Supabase and linked to the signed-in user.

1. **Run the SQL setup**  
   Ensure you’ve run `supabase-table-setup.sql` in the Supabase SQL Editor (it now includes a `payments` table).

2. **Razorpay test keys**  
   Get Key ID and Secret from [Razorpay Dashboard → API Keys](https://dashboard.razorpay.com/app/keys) (use **Test** keys). Optionally set `RAZORPAY_KEY_ID` in `config.js` to pre-fill the form.

3. **Create a Razorpay order** (from this folder):
   ```powershell
   $env:RAZORPAY_KEY_ID="rzp_test_xxxx"
   $env:RAZORPAY_KEY_SECRET="your_secret"
   node scripts/create-razorpay-order.js
   ```
   Copy the printed Order ID.

4. **Open the combined test page**  
   With the server running (`npx serve -l 3000`), go to **http://localhost:3000/test-both.html**.

5. **Flow**  
   - Sign in with Google (Supabase).  
   - Enter your Razorpay Key ID and the Order ID from step 3.  
   - Click **Open Razorpay checkout** and complete a test payment.  
   - On success, the payment is stored in `public.payments` and the list “Your payments (from Supabase)” updates.
