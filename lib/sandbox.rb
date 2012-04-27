module Sandbox

  # keep track of the top-level classes we create, so we can destroy only those methods
  # if we get mixed in somewhere
  @@created_classes = []

  def self.add_class(klass)
    const_set_from_string(klass)
  end

  def self.add_attributes(klass, *attrs)
    self.const_get_from_string(klass).class_eval do
      attr_accessor *attrs

      # set up the 'initialize' method to assign the attributes
      define_method(:initialize) do |*value_hash|
        value_hash = value_hash.first
        value_hash ||= {}
        value_hash.each do |k, v|
          instance_variable_set("@#{k.to_s}", v)
        end
      end
    end
  end

  def self.add_method(klass, method_name, proc_obj=nil, &blk)
    self.const_get_from_string(klass).send(:define_method, method_name, proc_obj || blk)
  end

  def self.add_class_method(klass, method_name, proc_obj=nil, &blk)
    singleton = (
    class << self.const_get_from_string(klass); self end)
    singleton.send(:define_method, method_name, proc_obj || blk)
  end

  def self.cleanup!
    constants.each { |klass| remove_const klass }
  end

  def self.scoop!
    self.cleanup!
  end

  def self.created_classes
    @@created_classes
  end

  def self.const_get_from_string(klass)
    klass.split("::").inject(self) { |const, klass| const.const_get(klass) }
  end

  def self.const_set_from_string(delimited_klasses)
    # try to const_get before set const_set to avoid "already initialized" warnings
    delimited_klasses.split("::").inject(self) do |const, klass|
      const.constants.include?(klass.to_sym) ? const.const_get(klass) : const.const_set(klass, Class.new)
    end

    @@created_classes << delimited_klasses.split("::").first
    @@created_classes.uniq!
  end
end
