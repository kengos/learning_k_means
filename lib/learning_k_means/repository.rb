require 'csv'
module LearningKMeans
  class Repository

    def self.load!(filepath, label, items)
      {}.tap do |dataset|
        CSV.foreach(filepath, headers: true) do |row|
          dataset[row[label]] = Vector.elements(items.map{|v| Rational(row[v]) })
        end
      end
    end
  end
end