class SimpleDepth < Hash
  def initialize(start,stop,sequence,features)
    start= start.to_i 
    stop = stop.to_i
    start.upto(stop) do |x|
      self[x] = Position.new(x)
    end
    features.each do |f|
      f.start.upto(f.end) do |pos|
        next if pos < start or pos > stop
       ##use the feature sequence if provided, allow mismatches but not gaps..
        sequence = f.sequence.match(/\w/) ? f.sequence : sequence
        begin #get the base and increment the count
          base = sequence[(pos - f.start) - 1, 1].upcase
          self[pos].update(base, f.strand)
        rescue
          self[pos].errors += 1
        end   
      end
    end

    def to_xml
      result = []
      self.each_key do |pos|
        result << self[pos].to_hash
      end
      result.to_xml
    end
  
  end
end


class Position
  attr_accessor :A, :C, :G, :T, :position, :coverage, :errors
  
  def initialize(pos)
    @position = pos
    @A = {:plus => 0, :minus => 0, :total => 0}
    @C = {:plus => 0, :minus => 0, :total => 0}
    @G = {:plus => 0, :minus => 0, :total => 0}
    @T = {:plus => 0, :minus => 0, :total => 0}
    @coverage = 0
    @errors = 0 #a variable that counts the number of non-ACGT bases, X, N, -, etc 
  end

  def update(base,strand)
    strand = strand == '+' ? :plus : :minus
    self.send(base)[strand] += 1
    self.send(base)[:total] += 1
    self.coverage += 1
  end
  
  def to_hash
    hash = {}
    hash['A'] = self.A
    hash['C'] = self.C
    hash['G'] = self.G
    hash['T'] = self.T
    hash['coverage'] = self.coverage
    hash['errors'] = self.errors
    hash['position'] = self.position
    hash
  end

end