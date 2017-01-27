require "test_helper"
require "securerandom"

module X
  class WeightedExperimentTest < Minitest::Test

    class WeightedButtonExperiment
      include X::Experiment

      variant "green_button", weight: 20
      variant "blue_button", weight: 50
      variant "pink_button", weight: 30

      def initialize(user_id)
        @user_id = user_id
      end

      def unit
        @user_id
      end
    end

    def test_weighted_assignment_respects_weights
      result = {"green_button" => 0, "blue_button" => 0, "pink_button" => 0}

      10_000.times do |x|
        user_id = SecureRandom.random_number(1_000_000)
        variant = WeightedButtonExperiment.new(user_id).assignment
        result[variant] += 1
      end

      assert_in_delta 2000, result["green_button"], 100
      assert_in_delta 5000, result["blue_button"], 250
      assert_in_delta 3000, result["pink_button"], 150
    end
  end
end
