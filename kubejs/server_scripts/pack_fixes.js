//v2
ServerEvents.recipes(event => {
  // XP nuggets → Liquid Experience on a plain Item Drain
  // (same 3 mB/nugget as CEI's grindstone recipe — Sable workaround)
  event.custom({
    type: 'create:emptying',
    ingredients: [{ item: 'create:experience_nugget' }],
    results: [{ id: 'create_enchantment_industry:experience', amount: 3 }]
  })

  // Crushed Raw Lead → Lead Ingot (re-adds CGS's broken 1.20.1-format recipes)
  // The blasting line also enables Bulk Blasting via encased fan + lava
  event.blasting('cgs:lead_ingot', 'create:crushed_raw_lead').xp(0.1)
  event.smelting('cgs:lead_ingot', 'create:crushed_raw_lead').xp(0.1)
})