RSpec::Matchers.define :have_field do |expected|
  chain :of_type do |type|
    @type = type
  end

  match do |model|
    has_field = model.fields.has_key?(expected.to_s)

    if @type
      has_field && (model.fields[expected.to_s] == @type)
    else
      has_field
    end
  end

  description do
    if @type
      "have field \"#{expected}\" of type \"#{@type}\""
    else
      "have field \"#{expected}\""
    end
  end
end

RSpec::Matchers.define :have_relationship do |expected|
  chain :on do |association|
    @association = association
  end

  match do |model|
    has_relationship = !model.relationships[expected.to_s].empty?

    if @association
      has_relationship && model.relationships[expected.to_s].include?(@association)
    else
      has_relationship
    end
  end

  description do
    if @association
      "have relationship \"#{expected}\" on \"#{@association}\""
    else
      "have relationship \"#{expected}\""
    end
  end
end