class Object
  def to_openstruct
    self
  end
end

class Array
  def to_openstruct
    map{ |el| el.to_openstruct }
  end
end

class Hash
  def to_openstruct
    mapped = {}
    each{ |key,value| mapped[key] = value.to_openstruct }
    OpenStruct.new(mapped)
  end
end

module YAML
  def self.load_openstruct(source)
    self.load(source).to_openstruct
  end
end

class Bot::Config
  CONFIG = YAML.load_openstruct File.read("config.yml")

  def self.method_missing(sym, *args, &block)
    CONFIG.send sym
  end
end