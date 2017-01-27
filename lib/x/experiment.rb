require "digest/sha1"

module X

  class VariantsMissingError < StandardError; end

  module Experiment
    include Variants

    module ClassMethods
      include Variants
    end

    def self.included(includer)
      includer.extend ClassMethods
    end

    def name
      self.class
    end

    def all_variants
      if self.class.respond_to?(:variants)
        [variants + self.class.variants].flatten.compact
      else
        variants
      end
    end

    def unit
      nil
    end

    def assignment
      run[:assignment]
    end

    def run
      raise VariantsMissingError unless all_variants.any?

      payload = {
        name:       name.to_s,
        assignment: get_assignment,
        exposure:   exposure,
        unit:       unit,
        variants:   all_variants.map(&:name)
      }

      if exposed? && respond_to?(:on_assignment)
        __send__(:on_assignment, payload)
      end

      payload
    end

    def enabled?
      true
    end

    def exposed?
      enabled? &&
        exposure >= (digest_contents / MAX)
    end

    def exposure
      1.0
    end

    private

      # Highest 15 hex digit integer value we'd return for any hashed experiment.
      # This technique is the same thing that https://github.com/facebook/planout
      # uses to hash experiments and assign variants.
      MAX = Float(0xFFFFFFFFFFFFFFF) # 1152921504606846975

      def digest_contents
        Digest::SHA1.hexdigest("#{name}.#{salt}.#{unit}")[0..14].to_i(16)
      end

      def exposure_target(max = 1.0)
        max * (digest_contents / MAX)
      end

      # Additional parameter used to digest experiment contents. Override this
      # to reset the experiment at any point.
      def salt
        nil
      end

      def get_assignment
        if exposed?
          assignment_variant.name
        else
          nil
        end
      end

      def assignment_variant
        if all_variants.any?(&:weight)
          weighted_assign
        else
          uniform_assign
        end
      end

      def uniform_assign
        index = digest_contents % all_variants.length
        all_variants[index]
      end

      def weighted_assign
        total_weight  = all_variants.map(&:weight).inject(:+)
        target        = exposure_target(total_weight)

        all_variants.each do |variant|
          return variant if variant.weight >= target
          target -= variant.weight
        end
      end
  end
end
