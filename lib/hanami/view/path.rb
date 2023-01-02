# frozen_string_literal: true

require "pathname"
require "dry/core/cache"

module Hanami
  class View
    # @api private
    class Path
      include Dry::Equalizer(:dir, :root)

      attr_reader :dir, :root

      def self.[](path)
        if path.is_a?(self)
          path
        else
          new(path)
        end
      end

      def initialize(dir, root: dir)
        @dir = Pathname(dir)
        @root = Pathname(root)
      end

      # Search for a template using a wildcard for the engine extension
      def lookup(name, format)
        glob = dir.join("#{name}.#{format}.*")
        Dir[glob].first
      end

      def chdir(dirname)
        self.class.new(dir.join(dirname), root: root)
      end

      def to_s
        dir.to_s
      end

      private

      def root?
        dir == root
      end

      def lookup_in_child_dirs(name, format, child_dirs:)
        child_dirs.reduce(nil) { |_, dir|
          template = chdir(dir).lookup(name, format)
          break template if template
        }
      end

      def lookup_in_parent_dir(name, format, child_dirs:)
        !root? && chdir("..").lookup(name, format, child_dirs: child_dirs, parent_dir: true)
      end
    end
  end
end
