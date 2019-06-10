# frozen_string_literal: true

# patch https://github.com/rails/sprockets/pull/257
# remove this when upgrading sprockets to version >= 4.0.1

Sprockets::Cache.class_eval do
  # Public: Clear cache
  #
  # Returns truthy on success, potentially raises exception on failure
  def clear(_options = nil)
    @cache_wrapper.clear
    @fetch_cache.clear
  end
end

Sprockets::Cache::GetWrapper.class_eval do
  def clear(options = nil)
    # dalli has a #flush method so try it
    if cache.respond_to?(:flush)
      cache.flush(options)
    else
      cache.clear(options)
    end
    true
  end
end

Sprockets::Cache::HashWrapper.class_eval do
  def clear(_options = nil)
    cache.clear
    true
  end
end

Sprockets::Cache::ReadWriteWrapper.class_eval do
  def clear(options = nil)
    cache.clear(options)
    true
  end
end

Sprockets::Cache::FileStore.class_eval do
  # Public: Clear the cache
  #
  # adapted from ActiveSupport::Cache::FileStore#clear
  #
  # Deletes all items from the cache. In this case it deletes all the entries in the specified
  # file store directory except for .keep or .gitkeep. Be careful which directory is specified
  # as @root because everything in that directory will be deleted.
  #
  # Returns true
  def clear(_options = nil)
    return true unless File.directory?(@root)

    root_dirs = Dir.entries(@root).reject do |f|
      (ActiveSupport::Cache::FileStore::EXCLUDED_DIRS + ActiveSupport::Cache::FileStore::GITKEEP_FILES).include?(f)
    end
    FileUtils.rm_r(root_dirs.collect { |f| File.join(@root, f) })
    true
  end
end

Sprockets::Cache::MemoryStore.class_eval do
  # Public: Clear the cache
  #
  # Returns true
  def clear(_options = nil)
    @cache.clear
    true
  end
end

Sprockets::Cache::NullStore.class_eval do
  # Public: Simulate clearing the cache
  #
  # Returns true
  def clear(_options = nil)
    true
  end
end
