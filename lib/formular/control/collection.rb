module Formular
  class Builder
    class Collection < Input
      def call(attributes, options={}, html="", &block)
        options[:collection].each_with_index do |model, i|
          html << item(model, i, attributes, options, &block)
        end

        html
      end

      def error(*args, &block)
        call(*args, &block)
      end

    private
      def item(model, i, attributes, options, &block)
        yield(model: model, index: i)
      end

      class Checkbox < Collection
        include Id

        # Invoked per item.
        def item(model, i, attributes, options, &block)
          item_options = {
            value: value = model.last,
            label: model.first,
            append_brackets: true,
            checked: options[:checked].include?(value),
            skip_hidden: i < options[:collection].size-1,
            id: id_for(options[:name], options.merge(suffix: [value])),
            skip_suffix: true,
          }

          yield(model: model, options: item_options, index: i) # usually checkbox(options) or something.
        end
      end

      class Radio < Collection
        include Id

        # Invoked per item.
        def item(model, i, attributes, options, &block)
          item_options = {
            value: value = model.last,
            label: model.first,
            checked: options[:checked].include?(value),
            id: id_for(options[:name], options.merge(suffix: [value])),
            skip_suffix: true,
          }

          yield(model: model, options: item_options, index: i) # usually checkbox(options) or something.
        end
      end
    end

    class Select < Collection
      def call(attributes, options, &block)
        @tag.(:select, attributes: attributes, content: super)
      end

      def option(content, attributes)
        checked!(attributes, {}, :selected)
        @tag.(:option, content: content, attributes: attributes)
      end

    private
      include Checked

      # def render_option(cfg, i, options)
      def item(item, i, attributes, options, &block)
        block_given? ?
          yield(self, model: item, index: i) :                                        # user leverages DSL.
          option(item.first, value: item.last, selected: options[:selected].include?(item.last)) # automatically create <option>.
      end
    end
  end
end
