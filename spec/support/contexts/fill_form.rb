RSpec.shared_context :fill_form do |form_id|

  let(:form_prefix) do
    form_id.sub(/^(new|edit)_/, '')
  end

  before do
    attributes.each do |k, value|
      input_id = "#{form_prefix}_#{k}"
      smart_fill_in(input_id, value)
    end
  end

  def smart_fill_in(id, value)
    field = page.find_by_id(id, visible: :all)
    tag_name = field.tag_name

    case
    when value.is_a?(Proc)
      value.call
    when value.is_a?(Array) && tag_name == 'select'
      value.each { |v| select(v, from: id) }
    when tag_name == 'input' && field['type'] == 'checkbox'
      check(id)
    when tag_name == 'select'
      select(value, from: id)
    else
      field.set(value)
    end
  end

  def click_on_submit
    page.find('input[type=submit]').click
  end

end
