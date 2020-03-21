defmodule ArtStoreWeb.InputHelpers do
  use Phoenix.HTML

  def input(form, field, options \\ []) do
    type = options[:using] || Phoenix.HTML.Form.input_type(form, field)
    label_value = options[:label] || humanize(field)

    wrapper_options = [class: "field #{state_class(form, field)}"]
    input_options = [] # To pass custom options to input

    validations = Phoenix.HTML.Form.input_validations(form, field)
    input_options = Keyword.merge(validations, input_options)

    content_tag :div, wrapper_options do
      label = label(form, field, label_value)
      input = input(type, form, field, input_options)
      error = ArtStoreWeb.ErrorHelpers.error_tag(form, field) || ""
      [label, input, error]
    end
  end

  defp state_class(form, field) do
    cond do
      form.errors[field] -> "error"
      true -> nil
    end
  end

  defp input(type, form, field, input_options) do
    apply(Phoenix.HTML.Form, type, [form, field, input_options])
  end
end
