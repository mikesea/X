lib = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "x"
require "pry"

class UserExperiments
  include X::Experiment

  attr_accessor :user_id

  def self.inherited(inheriter)
    @experiments ||= []
    @experiments << inheriter
  end

  def initialize(user_id, params = {})
    @user_id = user_id
  end

  def unit
    user_id
  end
end

class MyExperiment < UserExperiments
  variant "control"
  variant "variant"
  variant "foobar"

  def on_assignment(data)
    DbJob.perform_later(data)
  end
end

class DbJob
  def self.perform_later(data)
    puts data.inspect
  end
end

puts ex = MyExperiment.new(1234)
puts ex.assignment
puts ex.exposed?

puts ex = MyExperiment.new(12345)
puts ex.assignment
puts ex.exposed?

puts ex = MyExperiment.new(1234333)
puts ex.assignment
puts ex.exposed?
