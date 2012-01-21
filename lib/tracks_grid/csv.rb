module TracksGrid
  module CSV
    
    def to_csv(separator=',')
      rows.map{|row|row.join separator}.join("\n")
    end
    
  end
end