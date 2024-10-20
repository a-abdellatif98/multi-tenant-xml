module Callbacks
  def validate_age
    if age < 18 || age > 60
      errors.add(:age, 'must be between 18 and 60')
      throw :abort
    end
  end
end

