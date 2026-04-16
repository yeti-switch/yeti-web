# TODO

## Rate Management Project form - nullable boolean fields with include_blank: false

`app/admin/rate_management/projects.rb` has `include_blank: false` on:
- `reverse_billing` — nullable in DB (`default(FALSE)`, no NOT NULL constraint)
- `routing_tag_mode_id` — nullable in DB (`default(0)`, no NOT NULL constraint), validation uses `allow_nil: true`

Check whether these fields should actually allow nil (user should be able to clear them),
in which case `include_blank: false` is wrong and should be removed.

Compare with:
- `enabled` — NOT NULL in DB, validates inclusion without allow_nil → `include_blank: false` is correct
- `exclusive_route` — NOT NULL in DB → `include_blank: false` is correct
