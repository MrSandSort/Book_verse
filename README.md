# Verses — setup guide

This is the same flip-book prototype, now backed by a real Supabase database.
Public visitors can only read; only you (the single admin account) can
add, edit, or delete poems from `/admin`.

```
verses-book/
├── index.html              the public book (cover, flip pages, Cast & Themes)
├── admin.html               private admin panel — reachable only by direct URL
├── js/
│   ├── config.example.js    template — copy is already at config.js
│   ├── config.js            your real Supabase URL + anon key go here (gitignored)
│   └── supabase-client.js   builds the shared supabase-js client from config.js
├── supabase/
│   └── migration.sql        creates the poems table, RLS policies, and seed data
└── .gitignore
```

## 1. Create the Supabase project

1. Go to [supabase.com](https://supabase.com) and create a new project (any name/region is fine).
2. Wait for provisioning to finish, then open **Project Settings → API**.
3. Copy the **Project URL** and the **anon public** key — you'll need both in step 3.

## 2. Run the migration

1. In the Supabase dashboard, open **SQL Editor**.
2. Paste in the contents of `supabase/migration.sql` and run it.
3. This creates the `poems` table, enables Row Level Security, adds policies so
   anyone can read but only signed-in users can write, and seeds the six poems
   from the original prototype (delete that last block first if you'd rather
   start empty).

## 3. Fill in your config

Open `js/config.js` and replace the placeholders:

```js
window.VERSES_CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT-REF.supabase.co",
  SUPABASE_ANON_KEY: "YOUR-ANON-PUBLIC-KEY",
};
```

The anon key is safe to ship in frontend code — it's the public key, and Row
Level Security (from the migration) is what actually enforces "reads are
public, writes require login." `js/config.js` is gitignored anyway so it
won't accidentally end up in a public repo if you go that route.

## 4. Create your admin login

Supabase Auth needs one account for you — there's no public sign-up.

1. In the dashboard, go to **Authentication → Users → Add user**.
2. Enter your email and a password. You can either send an invite email or
   set the password directly and confirm the user immediately — either
   works, since sign-up is never exposed publicly.
3. That's the only account that will ever be able to log into `/admin`.

## 5. Try it locally

Any static file server works — for example:

```bash
cd verses-book
python3 -m http.server 8080
```

Then visit:
- `http://localhost:8080/` — the public book
- `http://localhost:8080/admin.html` — sign in with the account from step 4,
  add a poem, and it should appear in the book immediately in `sort_order`.

## 6. Deploy — GitHub Pages (via GitHub Actions + Secrets)

This repo includes `.github/workflows/deploy.yml`, which builds `js/config.js`
from GitHub Secrets at deploy time — so your real Supabase URL and anon key
never sit in the repo or its history, only in the deployed output.

**One-time setup:**

1. Push this folder to a new GitHub repo:
   ```bash
   cd verses-book
   git init
   git add .
   git commit -m "Initial commit: Verses book"
   git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git
   git branch -M main
   git push -u origin main
   ```
2. In the repo → **Settings → Secrets and variables → Actions → New repository secret**, add:
   - `SUPABASE_URL` — your project's URL
   - `SUPABASE_ANON_KEY` — your anon/publishable key
3. In the repo → **Settings → Pages**, set **Source** to **GitHub Actions**
   (not "Deploy from a branch").
4. Push again (or re-run the workflow from the **Actions** tab) — the workflow
   generates `js/config.js` from your secrets and publishes the site.

Your site will be live at `https://YOUR-USERNAME.github.io/YOUR-REPO-NAME/`.

**After that**, every `git push` to `main` re-deploys automatically. Editing
poems doesn't require a redeploy — that all happens live through `/admin.html`
against your Supabase database.

**Important:** in Supabase → **Authentication → URL Configuration**, add your
GitHub Pages URL (e.g. `https://YOUR-USERNAME.github.io`) as an allowed
Site URL / Redirect URL, or `/admin.html` login will fail on the live domain
even with correct credentials.

**Local testing still works the same way** — `js/config.js` stays gitignored,
so keep a local copy (filled in with your real values, from
`js/config.example.js`) for testing with `python3 -m http.server`. The
Actions workflow generates its own copy at deploy time; your local one never
gets pushed.

---

### Alternative: Vercel / Netlify

Both can also deploy this as-is (static folder, no build step). With either
of these, GitHub Actions isn't involved — you'd go back to committing
`js/config.js` directly (it's safe to, since the anon key is meant to be
public) or wiring their own environment/file-upload step instead.

**Vercel**
```bash
npm i -g vercel
cd verses-book
vercel
```

**Netlify**
```bash
npm i -g netlify-cli
cd verses-book
netlify deploy --prod
```

`/admin` is **not linked from the public site** — reach it by typing the URL
directly (e.g. `https://your-site.com/admin.html`). It shows nothing but a
login form to anyone who isn't signed in.

## What each page does

- **`index.html`** — cover screen → flip-book. Poems load from Supabase on
  open, ordered by `sort_order`. Each poem shows its `character_tag` as a
  small label under the title. The "↳ view by character" link on the
  contents page opens **Cast & Themes**, grouping every poem by its
  character/theme so you can follow one thread through the book.
- **`admin.html`** — sign in, then add/edit/delete poems against the same
  `poems` table. Changes show up in the public book on next load.

## Troubleshooting

- **"Missing configuration" banner on `/admin`, or the book won't leave its
  loading page** — `js/config.js` still has placeholder values; fill in your
  real Supabase URL and anon key.
- **Book says "the book could not be reached"** — check the browser console;
  usually a wrong URL/key in `config.js`, or the Supabase project is paused.
- **Can't sign into `/admin`** — confirm the user exists under
  **Authentication → Users** and that the password matches; Supabase's free
  tier pauses inactive projects after a week, which also blocks auth.# Book_verse
