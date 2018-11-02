class IbanValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      # IBAN code should start with country code (2 letters)
      if value !~ /^[A-Z]{2}/i
        record.errors.add(attribute, :invalid)
      end

      # Disallow bank TEST in production mode
      if Rails.env.production? && value =~ /^[A-Z]{2}[0-9]{2}TEST/i
        record.errors.add(attribute, :invalid)
      end

      iban = value.gsub(/[A-Z]/) { |p| (p.respond_to?(:ord) ? p.ord : p[0]) - 55 }
      if (iban[6..iban.length - 1].to_s + iban[0..5].to_s).to_i % 97 != 1
        record.errors.add(attribute, :invalid)
      end
    end
  end
end
