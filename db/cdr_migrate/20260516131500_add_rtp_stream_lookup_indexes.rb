class AddRtpStreamLookupIndexes < ActiveRecord::Migration[7.2]

  # rx_streams / tx_streams are RANGE-partitioned by time_start. A CREATE INDEX
  # on the partitioned parent (without ONLY) is cascaded by Postgres to every
  # existing and future partition, so these are plain single-column indexes —
  # no partition key needed (that requirement only applies to PK/UNIQUE).
  def up
    execute <<~SQL
      CREATE INDEX IF NOT EXISTS rx_streams_local_tag_idx
        ON rtp_statistics.rx_streams USING btree (local_tag);
      CREATE INDEX IF NOT EXISTS rx_streams_tx_stream_id_idx
        ON rtp_statistics.rx_streams USING btree (tx_stream_id);
      CREATE INDEX IF NOT EXISTS tx_streams_local_tag_idx
        ON rtp_statistics.tx_streams USING btree (local_tag);
    SQL
  end

  def down
    execute <<~SQL
      DROP INDEX IF EXISTS rtp_statistics.rx_streams_local_tag_idx;
      DROP INDEX IF EXISTS rtp_statistics.rx_streams_tx_stream_id_idx;
      DROP INDEX IF EXISTS rtp_statistics.tx_streams_local_tag_idx;
    SQL
  end

end
