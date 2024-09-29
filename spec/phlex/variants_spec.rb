# frozen_string_literal: true

RSpec.describe Phlex::Variants do
  it "has a version number" do
    expect(Phlex::Variants::VERSION).not_to be nil
  end

  it "allows defining base classes" do
    example = phlex_class do
      style do
        base "btn"
      end
    end

    actual_classes = example.build_style
    expected_classes = "btn"

    expect(actual_classes).to eq expected_classes
  end

  it "allows defining variants" do
    example = phlex_class do
      style do
        variants do
          color do
            primary "btn-primary"
            danger "btn-danger"
          end

          size do
            xs "btn-xs"
            md "btn-md"
            lg "btn-lg"
          end
        end
      end
    end

    actual_classes = example.build_style(color: :primary, size: :xs)
    expected_classes = "btn-primary btn-xs"

    expect(actual_classes).to eq expected_classes
  end

  it "allows defining default variants" do
    example = phlex_class do
      style do
        variants do
          color do
            primary "btn-primary"
            danger "btn-danger"
          end

          size do
            xs "btn-xs"
            md "btn-md"
            lg "btn-lg"
          end
        end

        defaults color: :primary, size: :md
      end
    end

    actual_classes = example.build_style
    expected_classes = "btn-primary btn-md"

    expect(actual_classes).to eq expected_classes

    actual_classes = example.build_style(color: :danger)
    expected_classes = "btn-danger btn-md"

    expect(actual_classes).to eq expected_classes
  end

  it "allows defining base, variants and default variants" do
    example = phlex_class do
      style do
        base "btn"

        variants do
          color do
            primary "btn-primary"
            danger "btn-danger"
          end

          size do
            xs "btn-xs"
            md "btn-md"
            lg "btn-lg"
          end
        end

        defaults color: :primary, size: :md
      end
    end

    actual_classes = example.build_style(color: :danger)
    expected_classes = "btn btn-danger btn-md"

    expect(actual_classes).to eq expected_classes
  end

  it "allows accessing build_style as class method and instance method" do
    example = phlex_class do
      style do
        base "btn"

        variants do
          color do
            primary "btn-primary"
            danger "btn-danger"
          end

          size do
            xs "btn-xs"
            md "btn-md"
          end
        end

        defaults color: :primary, size: :md
      end

      def initialize(color:, size:)
        @color = color
        @size = size
      end

      def view_template
        a(class: build_style(color: @color, size: @size)) do
          "Hello Variants"
        end
      end
    end

    actual_classes = example.build_style(color: :danger)
    actual_html = example.new(color: :danger, size: :xs).call
    expected_classes = "btn btn-danger btn-md"
    expected_html = '<a class="btn btn-danger btn-xs">Hello Variants</a>'

    expect(actual_classes).to eq expected_classes
    expect(actual_html).to eq expected_html
  end

  it "raises error with non existent variants" do
    example = phlex_class do
      style do
        variants do
          color do
            primary "btn-primary"
            danger "btn-danger"
          end
        end
      end
    end

    expect do
      example.build_style(color: :warning)
    end.to raise_error(Phlex::Variants::VariantNotFoundError, "Variant `color: :warning` doesn't exist")

    expect do
      example.build_style(disabled: true)
    end.to raise_error(Phlex::Variants::VariantNotFoundError, "Variant `disabled: true` doesn't exist")
  end

  it "allows defining boolean variants" do
    example = phlex_class do
      style do
        variants do
          outline do
            yes "btn-outline"
          end

          full do
            yes "btn-full"
            no "btn-fit"
          end

          loading do
            yes "btn-loading"
            no "btn-normal"
          end
        end

        defaults loading: false
      end
    end

    expect(example.build_style).to eq "btn-normal"
    expect(example.build_style(outline: true, full: false)).to eq "btn-normal btn-outline btn-fit"
    expect(example.build_style(loading: :yes, full: :no)).to eq "btn-loading btn-fit"
  end

  it "ignores nil variants" do
    example = phlex_class do
      style do
        base "btn"

        variants do
          color do
            primary "btn-primary"
            danger "btn-danger"
          end

          size do
            xs "btn-xs"
            md "btn-md"
          end
        end

        defaults color: :primary, size: :md
      end
    end

    actual_classes = example.build_style(color: nil, size: nil)
    expected_classes = "btn btn-primary btn-md"

    expect(actual_classes).to eq expected_classes
  end

  it "accepts extra classes" do
    example = phlex_class do
      style do
        base "btn"

        variants do
          color do
            primary "btn-primary"
            danger "btn-danger"
          end

          size do
            xs "btn-xs"
            md "btn-md"
          end
        end

        defaults color: :primary, size: :md
      end
    end

    actual_classes = example.build_style(color: :danger, extra_classes: "disabled:hidden")
    expected_classes = "btn btn-danger btn-md disabled:hidden"

    expect(actual_classes).to eq expected_classes
  end

  it "explains propery when calling undefined method from StyleBuilder" do
    msg = "undefined method 'color' for an instance of Phlex::Variants::StyleBuilder. The available methods are: 'base', 'variants' and 'defaults'"

    expect do
      phlex_class do
        style do
          color do
            red "bg-red-200 hover:bg-red-400"
          end
        end
      end
    end.to raise_error(NoMethodError, msg)
  end

  def phlex_class(&)
    Class.new(Phlex::HTML) do
      include Phlex::Variants

      class_eval(&)
    end
  end
end
