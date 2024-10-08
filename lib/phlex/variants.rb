# frozen_string_literal: true

require "phlex"

require_relative "variants/version"

module Phlex
  module Variants
    VariantNotFoundError = Class.new(StandardError)

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def style(&)
        StyleBuilder.build(self, &)
      end

      def build_style(**variants)
        extra_classes = variants.delete(:extra_classes)

        [self::STYLE_BASE, build_variants_style(variants), extra_classes].flatten.compact.join(" ")
      end

      private

      # @api private
      def build_variants_style(variants)
        variants = variants.compact
        variants = self::STYLE_DEFAULTS.merge(variants) unless self::STYLE_DEFAULTS.empty?

        variants.map do |variant, option|
          options = self::STYLE_VARIANTS[variant]

          if options
            value = options[option]

            next value if value

            # doesn't raise error when passing false for variant with only true option
            next if option == false && options.has_key?(true)
          end

          raise_variant_not_found_error(options, variant, option)
        end
      end

      def raise_variant_not_found_error(options, variant, option)
        message = if options
          "Option #{option.inspect} for #{variant.inspect} variant doesn't exist. Valid options are: #{options.keys}"
        else
          "Variant #{variant.inspect} doesn't exist. Available variants are: #{self::STYLE_VARIANTS.keys}"
        end

        raise VariantNotFoundError, message
      end
    end

    private

    def build_style(...)
      self.class.build_style(...)
    end

    # @api private
    class StyleBuilder
      attr_reader :view_class

      def self.build(view_class, &)
        new(view_class).build(&)
      end

      def build(&)
        view_class.const_set(:STYLE_BASE, [])
        view_class.const_set(:STYLE_VARIANTS, {})
        view_class.const_set(:STYLE_DEFAULTS, {})
        instance_exec(&)
      end

      private

      def initialize(view_class)
        @view_class = view_class
      end

      def base(*values)
        view_class::STYLE_BASE.concat values
      end

      def variants(&)
        VariantBuilder.build(view_class, &)
      end

      def defaults(**variants)
        view_class::STYLE_DEFAULTS.merge!(variants)
      end

      def method_missing(method, *args, &) # standard:disable Style/MissingRespondToMissing
        message = "undefined method '#{method}' for an instance of Phlex::Variants::StyleBuilder. The available methods are: 'base', 'variants' and 'defaults'"
        raise NoMethodError, message
      end
    end

    # @api private
    class VariantBuilder
      attr_reader :view_class

      def self.build(view_class, &)
        new(view_class).instance_exec(&)
      end

      def initialize(view_class)
        @view_class = view_class
      end

      def method_missing(name, &) # standard:disable Style/MissingRespondToMissing
        variant_name = name.to_sym
        view_class::STYLE_VARIANTS[variant_name] = {}
        OptionsBuilder.build(view_class, variant_name, &)
      end
    end

    # @api private
    class OptionsBuilder
      attr_reader :view_class, :variant_name

      def self.build(view_class, variant_name, &)
        new(view_class, variant_name).instance_exec(&)
      end

      private

      def initialize(view_class, variant_name)
        @view_class = view_class
        @variant_name = variant_name
      end

      def method_missing(name, *args) # standard:disable Style/MissingRespondToMissing
        option = name.to_sym

        if option == :yes
          view_class::STYLE_VARIANTS[variant_name][true] = args
        elsif option == :no
          view_class::STYLE_VARIANTS[variant_name][false] = args
        else
          view_class::STYLE_VARIANTS[variant_name][option] = args
        end
      end
    end
  end
end
