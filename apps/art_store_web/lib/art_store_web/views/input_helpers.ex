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

  def array_input(form, field) do
    values = Phoenix.HTML.Form.input_value(form, field) || [""]
    id = Phoenix.HTML.Form.input_id(form,field)
    type = Phoenix.HTML.Form.input_type(form, field)
    content_tag :ol, id: container_id(id), class: "input_container", data: [index: Enum.count(values) ] do
    values
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        new_id = id <> "_#{index}"
        input_opts = [
          name: new_field_name(form,field),
          value: value,
          id: new_id,
          class: "form-control"
        ]
        form_elements(form,field, value, index)
      end)
    end
  end

  defp form_elements(form, field, value, index) do
    type = Phoenix.HTML.Form.input_type(form, field)
    id = Phoenix.HTML.Form.input_id(form,field)
    new_id = id <> "_#{index}"
    input_opts = [
      name: new_field_name(form,field),
      value: value,
      id: new_id,
      class: "form-control"
    ]
    content_tag :li do
      [
        apply(Phoenix.HTML.Form, type, [form, field, input_opts]),
        link("Remove", to: "#", data: [id: new_id], title: "Remove", class: "remove-form-field")
       ]
     end
  end

  defp container_id(id), do: id <> "_container"

  defp new_field_name(form, field) do
    Phoenix.HTML.Form.input_name(form, field) <> "[]"
  end

  def array_add_button(form, field) do
    id = Phoenix.HTML.Form.input_id(form,field)
    content = form_elements(form,field,"","__name__")
      |> safe_to_string
    data = [
      prototype: content,
      container: container_id(id)
    ];
    link("Add", to: "#",data: data, class: "add-form-field")
  end
end
