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

RSpec::Matchers.define :have_relation do |expected|
  chain :for_associated do |associated|
    @associated = associated
  end

  match do |model|
    relation = model.relations.find { |rel| rel.name == expected.to_s }

    if @associated
      relation && relation.association == @associated.to_s
    else
      relation
    end
  end

  description do
    if @associated
      "have relation \"#{expected}\" for associated \"#{@associated}\""
    else
      "have relation \"#{expected}\""
    end
  end
end
