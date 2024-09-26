> [!WARNING]
> Please note that Phlex::Variants is currently under development and may undergo changes to its API before reaching the stable release (1.0.0). As a result, there may be breaking changes that affect its usage.

# Phlex::Variants
[![CI](https://github.com/stephannv/phlex-variants/actions/workflows/main.yml/badge.svg)](https://github.com/stephannv/phlex-variants/actions/workflows/main.yml)

Phlex::Variants enables variants feature to Phlex view. It is useful if you are building components using a utility-first
CSS framework like Tailwind CSS.

- [Installation](#installation)
- [Usage](#usage)
- [How it works](#how-it-works)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add phlex-variants
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install phlex-variants
```

> [!TIP]
> If you prefer not to add another dependency to your project, you can simply copy the [Phlex::Variants](https://github.com/stephannv/phlex-variants/blob/main/lib/phlex/variants.rb) file into your project.


## Usage

To create a component with style variants, include the `Phlex::Variants` module and use the `style` method to define the
base classes, variants, and default values.

```ruby
class Button < Phlex::HTML
  include Phlex::Variants

  style do
    base "btn"

    variants do
      color do
        default "btn-default"
        primary "btn-primary"
        danger "btn-danger"
      end

      size do
        xs "btn-xs"
        md "btn-md"
        lg "btn-lg"
      end

      outline do
        yes "btn-outline"
      end
    end

    defaults color: :default, size: :md
  end

  attr_reader :color, :size, :outline

  def initialize(color: nil, size: nil, outline: nil)
    @color = color
    @size = size
    @outline = outline
  end

  def view_template(&)
    a(class: build_style(color:, size:, outline:), &)
  end
end

Button.new.call { "Hello" }
# => "<a class="btn btn-default btn-md">Hello<a>"

Button.new(color: :primary, size: :lg, outline: true).call { "Hello" }
# => "<a class="btn btn-primary btn-lg btn-outline">Hello<a>"

Button.build_style(color: :danger, size: :xs)
# => "btn btn-danger btn-xs"
```

## How it works

#### `style`

The `style` method is used to define the styling configuration of your component. It includes the following sections:

- `base`: Defines the base CSS class that will always be applied to the component.
- `variants`: Allows you to define multiple variants with different options for each variant group (e.g., color, size).
- `defaults`: Sets the default values for the variants.

You can use `yes`/`no` as variant options, which can be accessed by passing `true`/`false` when calling the `build_style`
method.

#### `build_style`

The `build_style` is both instance method and class method, it generates CSS classes string based on given variants.

- If a variant is passed as nil, the default value defined in defaults will be used. For example, if `defaults size: :xs`
is set and `build_style(size: nil)` is called, the `size: :xs` will be used to build the class result.

- If a non-existent variant or option is passed, it will raise a `Phlex::Variants::VariantNotFoundError`.

- Use `true`/`false` to toggle `yes`/`no` options in boolean variants.

- You can add additional classes using the `extra_classes` option. These will be appended to the final class string:
```ruby
build_style(color: :primary, extra_classes: "disabled:hidden")
# => "btn btn-danger btn-xs disabled:hidden"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stephannv/phlex-variants. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stephannv/phlex-variants/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Phlex::Variants project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stephannv/phlex-variants/blob/master/CODE_OF_CONDUCT.md).
