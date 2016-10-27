class Movie < ActiveRecord::Base
    validates :title, :presence => true
    validate :released_1930_or_later
    
    def released_1930_or_later
        errors.add(:release_date, 'must be 1930 or later') if 
            release_date && release_date < Date.parse('1 Jan 1930')
    end
end
