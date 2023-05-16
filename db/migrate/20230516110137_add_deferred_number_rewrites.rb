class AddDeferredNumberRewrites < ActiveRecord::Migration[7.0]
  def up
    execute %q{
        alter table class4.numberlist_items
            add defer_src_rewrite boolean not null default false,
            add defer_dst_rewrite boolean not null default false;

        alter table class4.numberlists
            add defer_src_rewrite boolean not null default false,
            add defer_dst_rewrite boolean not null default false;
    }
  end

  def down
    execute %q{
        alter table class4.numberlist_items
            drop column defer_src_rewrite,
            drop column defer_dst_rewrite;

        alter table class4.numberlists
            drop column defer_src_rewrite,
            drop column defer_dst_rewrite;
    }
  end
end
