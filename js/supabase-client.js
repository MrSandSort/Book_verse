
(function () {
  const cfg = window.VERSES_CONFIG;
  if (!cfg || !cfg.SUPABASE_URL || !cfg.SUPABASE_ANON_KEY) {
    console.error(
      "Verses: missing config.js — copy js/config.example.js to js/config.js and fill in your Supabase URL + anon key."
    );
    window.verses = { supabase: null, configError: true };
    return;
  }

  const client = supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);
  window.verses = { supabase: client, configError: false };
})();
