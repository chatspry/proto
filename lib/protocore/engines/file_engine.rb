module Protocore
  module Engines
    class FileEngine

      def commit
        cache.each { |key, content| write(key, content) }
      end

      def get(key, &blk)
        content = cache.fetch(key) { read(key) if exists?(key) }
        block_given? ? blk.call(content) : content if content
      end

      def set(key, content)
        cache[key] = content
      end

      def exists?(key)
        File.exists?(key)
      end

      def cache
        @cache ||= {}
      end

    private

      def read(key)
        File.read(key)
      end

      def write(key, content)
        FileUtils.mkdir_p Pathname(key).dirname
        File.open(key, "w") { |file| file.write content }
      end

    end
  end
end