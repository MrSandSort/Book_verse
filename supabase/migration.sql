-- Verses: schema + row-level security
-- Run this in the Supabase SQL editor (or via `supabase db push`) once per project.

-- 1. Table -------------------------------------------------------------

create table if not exists public.poems (
  id             uuid primary key default gen_random_uuid(),
  title          text not null,
  body           text not null,
  character_tag  text not null,
  sort_order     integer not null default 0,
  created_at     timestamptz not null default now()
);

-- Keep reads fast and predictable in sort_order
create index if not exists poems_sort_order_idx on public.poems (sort_order);

-- 2. Row Level Security --------------------------------------------------

alter table public.poems enable row level security;

-- Anyone (including anonymous visitors) may read poems.
drop policy if exists "poems_public_read" on public.poems;
create policy "poems_public_read"
  on public.poems
  for select
  to anon, authenticated
  using (true);

-- Only a signed-in user (the single admin account) may write.
drop policy if exists "poems_admin_insert" on public.poems;
create policy "poems_admin_insert"
  on public.poems
  for insert
  to authenticated
  with check (true);

drop policy if exists "poems_admin_update" on public.poems;
create policy "poems_admin_update"
  on public.poems
  for update
  to authenticated
  using (true)
  with check (true);

drop policy if exists "poems_admin_delete" on public.poems;
create policy "poems_admin_delete"
  on public.poems
  for delete
  to authenticated
  using (true);

-- 3. Seed data (optional) -------------------------------------------------
-- The six poems from the original static prototype, so the book isn't
-- empty the first time you deploy. Safe to delete this block if you'd
-- rather start from a blank book and add poems via /admin.

insert into public.poems (title, character_tag, sort_order, body) values
('Threshold of March', 'The Wanderer', 1, $$Snow surrenders its ground by inches,
reluctant, silver, half in love with cold.
The crocus does not ask permission—
it simply arrives, small and gold.

Somewhere a window opens for the first time
since November learned our names.
We stand in it, unpracticed at the light,
learning our faces again.$$),
('Harbor Light', 'The Keeper', 2, $$The lighthouse keeps a lonely arithmetic,
counting the dark in five-second turns.
Every ship that passes owes it nothing
but the fact of having passed.

I have loved like that—
turning toward whoever needed the light,
asking only that they arrive somewhere
safer than where they began.$$),
('Kitchen, Late', 'The Keeper', 3, $$The kettle knows before I do
that sleep isn't coming.
It says so in its low, rising complaint,
a small domestic weather.

My mother used to stand here too,
same hour, same tired window,
teaching the dark to be ordinary
by simply outlasting it.$$),
('Inventory', 'Grief & Memory', 4, $$What the year left me:
a coat with a good pocket,
two phone numbers I no longer dial,
the particular blue of one October.

I did not choose these things.
They chose to stay,
the way certain birds
refuse to fly south, out of stubbornness, or love.$$),
('Field Notes', 'Grief & Memory', 5, $$The horses do not perform their grazing.
They simply lower their whole enormous quiet
into the grass, and mean it.

I have spent so many years
rehearsing how to rest
that I have nearly missed
how the horses do it: at once, completely.$$),
('Night Ferry', 'The Wanderer', 6, $$Between one shore and the other
there is no country at all—
only engines, salt, the small gold rooms
where strangers sleep sitting up.

I think this is what the soul does
between one life and the next:
not arrive, not depart,
but ride, wide awake, over black water.$$)
on conflict do nothing;
